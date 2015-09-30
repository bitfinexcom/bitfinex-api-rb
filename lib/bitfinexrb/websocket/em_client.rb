require 'bitfinexrb/websocket/processor'
module Bitfinexrb
  module Websocket
    #
    class EMClient
      def initialize(options = {})
        # set some defaults
        @url = options[:url] || 'wss://api2.bitfinex.com:3000/ws'
        @reconnect = options[:reconenct] || false
        @processor = EventProcessor.new(self)
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
        @ws.close
      end

      def connect!
        @ws = Faye::WebSocket::Client.new(@url)
        @ws.onopen = method(:ws_opened)
        @ws.onmessage = method(:ws_receive)
        @ws.onclose = method(:ws_closed)
        @ws.onerror = method(:ws_error)
      end

      def send(msg)
        msg = msg.is_a?(Hash) ? msg.to_json : msg
        @ws.send(msg)
      end

      def authenticate
        fail 'Missing API_KEY and API_SECRET ENV variables' if !ENV['API_KEY'] || !ENV['API_SECRET']
        payload = Base64.encode64("AUTH #{DateTime.now.to_s}").gsub(/\s/,'')
        sig = Digest::HMAC.hexdigest(payload, ENV['API_SECRET'], Digest::SHA384)
        @ws.send({Event: 'auth', ApiKey: ENV['API_KEY'], AuthSig: sig, AuthPayload: payload}.to_json)
      end

      def call_handler(chan, data, raw=nil)
        data.merge!(raw: raw) unless raw.nil?
        ivar = instance_variable_get("@#{chan}_cb")
        ivar.call(data) if ivar
        @message_cb.call(data) if @message_cb
      end

      private

      def ws_opened(event)
        @open_cb.call(event) if @open_cb
      end

      def ws_receive(event)
        @processor.process_incoming(event.data)
      end

      def ws_closed(_event)
        EM.stop
      end

      def ws_error(event)
        fail event
      end
    end
  end
end
