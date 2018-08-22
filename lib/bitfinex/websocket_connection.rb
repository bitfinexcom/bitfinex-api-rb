require 'eventmachine'
require 'faye/websocket'
require 'json'

module Bitfinex
  module WebsocketConnection

    def listen!
      @ws_auth = false
      subscribe_to_channels
      listen
      ws_client.run!
    end

    def ws_close
      @ws_open = false
      @ws_auth = false
      reset_auth_registration
      ws_client.stop
    end

    def ws_auth(dms: 0, calc: 0, &block)
      return if @ws_auth

      nonce = (Time.now.to_f * 10_000).to_i.to_s
      payload = 'AUTH' + nonce
      add_callback(:auth, &block)
      save_channel_id(:auth, 0)
      
      params = {
        event: 'auth',
        apiKey: config.api_key,
        authSig: sign(payload),
        authPayload: payload,
        authNonce: nonce,
        dms: dms,
        calc: calc
      }

      ws_safe_send(params)
    end

    def ws_unauth
      ws_safe_send({ event: 'unauth' })
      @ws_auth = false
    end

    def alive?
      ws_client.alive?
    end

    def chan_ids
      @chan_ids ||= []
    end

    def subscribe!
      ws_registration_messages.each do |msg|
        ws_client.send(msg)
      end
    end

    def unsubscribe!
      chan_ids.size.times.reject { |i| chan_ids[i].nil? }.each do |chan|
        ws_client.send({ 'event': 'unsubscribe', 'chanId': chan })
      end
    end

    def resubscribe(chan)
      ws_client.send({ 'event': 'unsubscribe', 'chanId': chan })
      register_channel chan_ids[chan].update(event: 'subscribe')
      callbacks[chan_ids[chan]] = nil
      chan_ids[chan] = nil
    end

    private

    def reset_auth_registration
      ws_registration_messages.delete_if { |i| i[:event] == 'auth' }
      @ws_auth = false
    end

    def ws_client
      options = {
        url: config.websocket_api_endpoint,
        reconnect: config.reconnect,
        reconnect_after: config.reconnect_after,
        reconnect_lag: config.reconnect_lag,
      }
      @ws_client ||= WebsocketClient.new(options)
    end

    def ws_open
      @ws_open ||= false
    end

    def ws_registration_messages
      @ws_registration_messages ||= []
    end

    def add_callback(channel, &block)
      callbacks[channel] = { block: block, chan_id: nil }
    end

    def ws_safe_send(msg)
      case ws_open
      when true then ws_client.send msg
      else ws_registration_messages.push msg
      end
    end

    def callbacks
      @callbacks ||= {}
    end

    def register_channel(msg, &block)
      add_callback(fingerprint(msg), &block)
      case @ws_open
      when true
        ws_client.send msg.merge(event: 'subscribe')
      else
        ws_registration_messages.push msg.merge(event: 'subscribe')
      end
    end

    def fingerprint(msg)
      msg.reject { |k, _v| [:event, 'pair', 'chanId', 'event'].include?(k) }
         .inject({}) { |h, (k, v)| h[k.to_sym] = v.to_s; h }
    end

    def listen
      ws_client.on :message do |rmsg|
        msg = JSON.parse(rmsg)
      
        if msg.is_a?(Hash) && msg['event'] == 'subscribed'
          save_channel_id(fingerprint(msg), msg['chanId'])
        elsif msg.is_a?(Hash) && msg["event"] == 'auth'
          if msg['status'] == 'FAILED'
            reset_auth_registration
            ws_auth(&callbacks[:auth][:block])
          elsif msg['status'] == 'OK'
            @ws_auth = true
            exec_callback_for(msg)
          end
        elsif msg.is_a?(Array)
          exec_callback_for(msg)
        elsif msg.is_a?(Hash) && msg['event'] == 'pong'
          ws_client.ping = (Time.now.utc.to_f * 1_000).to_i - msg['cid']
        elsif msg.is_a?(Hash) && msg["event"] == 'info'
          case msg['code']
          when 20051 # Stop/Restart signal
            ws_client.stop
          when 20060 # Entering in Maintenance mode
            unsubscribe!
            reset_auth_registration if @ws_auth
          when 20061 # Maintenance finished
            ws_auth(&callbacks[:auth][:block])
            subscribe!
          end
        end
      end

      ws_client.on :close do |_event|
        @ws_open = false
        if @ws_auth
          reset_auth_registration
          ws_auth(&callbacks[:auth][:block])
        end
      end        
    end

    def save_channel_id(chan,id)
      callbacks[chan][:chan_id] = id
      chan_ids[id.to_i] = chan
    end

    def exec_callback_for(msg)
      return if msg[1] == 'hb'
      id = msg[0].to_i
      callbacks[chan_ids[id]][:block].call(msg)
    end

    def subscribe_to_channels
      ws_client.on :open do
        ws_registration_messages.each do |msg|
          ws_client.send(msg)
        end
        @ws_open = true
      end
    end

    class WebsocketClient
      attr_accessor :ping

      def initialize(options = {})
        @url = options[:url] || 'wss://api.bitfinex.com/ws/2'
        @reconnect = options[:reconnect] || false
        @reconnect_after = options[:reconnect_after] || 30
        @reconnect_lag = options[:reconnect_lag] || 60
        @ping = nil
      end

      def on(msg, &blk)
        ivar = "@#{msg}_cb"
        instance_variable_set(ivar.to_sym, blk)
      end

      def run!
        if EventMachine.reactor_running?
          connect!
        else
          EM.run { connect! }
        end
      end

      def stop
        @ws.close
      end

      def stop!
        @stop = true
        @ws.close
      end

      def connect!
        @ws = Faye::WebSocket::Client.new(@url, nil, ping: 60)
        @ws.onopen = method(:ws_opened)
        @ws.onmessage = method(:ws_receive)
        @ws.onclose = method(:ws_closed)
        @ws.onerror = method(:ws_error)
      end

      def send(msg)
        unless closing? || closed?
          connect! unless alive? || connecting?
          msg = msg.is_a?(Hash) ? msg.to_json : msg
          @ws.send(msg)
        end
      end

      def connecting?
        @ws && @ws.ready_state == Faye::WebSocket::API::CONNECTING
      end

      def alive?
        @ws && @ws.ready_state == Faye::WebSocket::API::OPEN
      end

      def closing?
        @ws && @ws.ready_state == Faye::WebSocket::API::CLOSING
      end

      def closed?
        @ws && @ws.ready_state == Faye::WebSocket::API::CLOSED
      end

      private

      def ping_timer
        @ping_timer =
          EM::PeriodicTimer.new(5) do
            self.send({ 'event': 'ping', "cid": (Time.now.utc.to_f * 1_000).to_i })
          end          
      end

      def lag_timer
        @lag_timer =
          EM::PeriodicTimer.new(20) do
            if ping && ping > @reconnect_lag * 1_000
              stop
            end
          end          
      end

      def reconnect_timer
        @reconnect_timer = EM::PeriodicTimer.new(@reconnect_after) { run! }
      end

      def ws_opened(event)
        @reconnect_timer.cancel if @reconnect_timer
        ping_timer
        lag_timer
        @open_cb.call(event) if @open_cb
      end

      def ws_receive(event)
        @message_cb.call(event.data) if @message_cb
      end

      def ws_closed(_event)
        @close_cb.call(_event) if @close_cb
        @ping_timer.cancel
        @lag_timer.cancel
        @reconnect_timer.cancel if @reconnect_timer
        EM.stop if @stop
        
        sleep 2
        @ping = nil

        if @reconnect
          reconnect_timer
        end
      end

      def ws_error(event)
        raise WebsocketError, event.message
      end

    end
  end
end
