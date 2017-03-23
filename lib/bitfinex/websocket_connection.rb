require 'eventmachine'
require 'faye/websocket'
require 'json'

module Bitfinex
  module WebsocketConnection

    def listen!
      subscribe_to_channels
      listen
      ws_client.run!
    end

    def ws_send(msg)
      ws_client.send msg
    end

    def ws_close_all
      ws_client.stop!
      @ws_open = false
      ws_reset_channels
    end

    def ws_auth(&block)
      unless @ws_auth
        payload = 'AUTH' + (Time.now.to_f * 10_000).to_i.to_s
        signature = sign(payload)
        add_callback(:auth, &block)
        save_channel_id(:auth, 0)
        ws_safe_send({
          apiKey: config.api_key,
          authSig: sign(payload),
          authPayload: payload,
          event: 'auth'
        })
        @ws_auth = true
      end
    end

    def ws_unauth
      ws_safe_send({event: 'unauth'})
    end

    private

    def ws_reset_channels
      @chan_ids = []
      @ws_registration_messages = []
      @callbacks = {}
    end

    def ws_client
      options = {
        url: config.websocket_api_endpoint,
        reconnect: config.reconnect,
        reconnect_after: config.reconnect_after
      }
      @ws_client ||= WSClient.new(options)
    end

    def chan_ids
      @chan_ids ||= []
    end

    def ws_open
      @ws_open ||= false
    end

    def ws_registration_messages
      @ws_registration_messages ||= []
    end

    def callbacks
      @callbacks ||= {}
    end

    def add_callback(channel, &block)
      callbacks[channel] = { block: block, chan_id: nil }
    end

    def register_authenticated_channel(msg, &block)
      add_callback(fingerprint(msg),&block)
      ws_safe_send(msg.merge(event:'subscribe'))
    end

    def ws_safe_send(msg)
      if ws_open
        ws_client.send msg
      else
        ws_registration_messages.push msg
      end
    end

    def register_channel(msg, &block)
      add_callback(fingerprint(msg),&block)
      if ws_open
        ws_client.send msg.merge(event: 'subscribe')
      else
        ws_registration_messages.push msg.merge(event: 'subscribe')
      end
    end

    def fingerprint(msg)
      msg.reject{|k,v| [:event,'chanId','event'].include?(k) }.
          inject({}){|h, (k,v)| h[k.to_sym]=v.to_s; h}
    end

    def listen
      ws_client.on(:message) do |rmsg|
         msg = JSON.parse(rmsg)
         if msg.kind_of?(Hash) && msg["event"] == "subscribed"
           save_channel_id(fingerprint(msg), msg["chanId"])
         elsif msg.kind_of?(Array)
           exec_callback_for(msg)
         end
      end
    end

    def save_channel_id(chan,id)
      callbacks[chan][:chan_id] = id
      chan_ids[id.to_i] = chan
    end

    def exec_callback_for(msg)
      return if msg[1] == 'hb' #ignore heartbeat
      id = msg[0]
      callbacks[chan_ids[id.to_i]][:block].call(msg)
    end

    def subscribe_to_channels
      ws_client.on(:open) do
        @ws_open = true
        ws_registration_messages.each do |msg|
          ws_client.send(msg)
        end
      end
    end

    class WSClient
      def initialize(options = {})
        # set some defaults
        @url = options[:url] || 'wss://api.bitfinex.com/ws'
        @reconnect = options[:reconnect] || false
        @reconnect_after = options[:reconnect_after] || 30
        @stop = false
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

      def stop!
        @stop = true
        @ws.close
      end

      def connect!
        @stop = false
        @ws = Faye::WebSocket::Client.new(@url)
        @ws.onopen = method(:ws_opened)
        @ws.onmessage = method(:ws_receive)
        @ws.onclose = method(:ws_closed)
        @ws.onerror = method(:ws_error)
      end

      def send(msg)
        raise ConnectionClosed if stopped?
        connect! unless alive?
        msg = msg.is_a?(Hash) ? msg.to_json : msg
        @ws.send(msg)
      end

      def alive?
        @ws && @ws.ready_state == Faye::WebSocket::API::OPEN
      end

      def stopped?
        @stop
      end

      private

      def ws_opened(event)
        @open_cb.call(event) if @open_cb
      end

      def ws_receive(event)
        @message_cb.call(event.data) if @message_cb
      end

      def ws_closed(event)
        return unless @reconnect
        if @stop
          EM.stop
        else
          EM.add_timer(@reconnect_after){ connect! }
        end
      end

      def ws_error(event)
        fail event
      end
    end
  end
end
