module Bitfinexrb
  module Websocket
    #
    class EMClient
      def initialize(options = {})
        # set some defaults
        @url = options[:url] || 'ws://dev2.bitfinex.com:3001/ws'
        @reconnect = options[:reconenct] || false
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

      private

      def ws_opened(event)
        @open_cb.call(event) if @open_cb
      end

      def ws_receive(event)
        @message_cb.call(event.data) if @message_cb
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
