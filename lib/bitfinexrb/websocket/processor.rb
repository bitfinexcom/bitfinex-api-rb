require 'active_support'
module Bitfinexrb
  module Websocket
    class EventProcessor

      attr_accessor :channel_ids

      def initialize(ws)
        @channel_ids = []
        @ws_client = ws
      end

      def process_incoming(data)
        handle_json_response(JSON.parse(data)) if data[0] == '{'
        handle_str_response(data) if data[0] == '['
      end

      def handle_json_response(jsn)
        case jsn['Event']
        when 'subscribed'
          @channel_ids[jsn['ChanId']] = {type: jsn['Channel'], pair: jsn['Pair']}
          @ws_client.call_handler('subscribe', jsn)
        when 'auth'
          @channel_ids[jsn['UserId']] = 'private'
          @ws_client.call_handler('auth', jsn)
        end
      end

      def handle_str_response(str)
        chan_id, data = rubufy_pc_data(str)
        case @channel_ids[chan_id]
        when 'book'
          handle_book_data(chan_id, data)
        when 'trades'
          @ws_client.call_handler('trade', data)
        when 'ticker'
          @ws_client.call_handler('ticker', data)
        when 'private'
          @ws_client.call_handler('private', data)
        end
      end

      def handle_book_data(cid, data)
        m = {chan_id: cid}
        if data['data_snapshot']
          k = [:price, :count, :amount]
          m[:event] = 'book_snapshot'
          m[:data] = data['data_snapshot'].collect!{ |o| Hash[k.zip(o)] }
        else
          k = [:price, :count, :amount]
          m[:event] = 'book_update'
          m[:data] = Hash[k.zip(data['data'])]
        end
        @ws_client.call_handler(m[:event], m)
      end

      private

      def rubufy_pc_data(pc_data)
        tmparr = pc_data.split(',')
        chan_id = tmparr[0].gsub(/\[/, '').to_i
        if tmparr[0][0] == '['
          if tmparr[1][0] == '['
            ln = tmparr[0].length+1
            p ln
            valid_jsn = "{ \"data_snapshot\": #{pc_data[3..-2]} }"
          else
            valid_jsn = "{ \"data\": #{pc_data} }"
          end
          return chan_id, ActiveSupport::JSON.decode(valid_jsn)
        end
      end
    end
  end
end
