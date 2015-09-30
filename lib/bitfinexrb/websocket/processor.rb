require 'json'
require 'bigdecimal'
require 'oj'
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
          if jsn['Status'] == 'FAILED'
            @ws_client.call_handler('auth_failed', jsn)
          elsif jsn['Status'] == 'OK'
            @channel_ids[0] = {type: 'private'}
            @ws_client.call_handler('auth_success', jsn)
          end
        end
      end

      def handle_str_response(str)
        chan_id, data = rubufy_pc_data(str)
        case @channel_ids[chan_id][:type]
        when 'book'
          handle_book_data(chan_id, data)
        when 'trades'
          @ws_client.call_handler('trade', data, str)
        when 'ticker'
          @ws_client.call_handler('ticker', data, str)
        when 'private'
          handle_private_data(str)
          @ws_client.call_handler('private', data, str)
        end
      end

      def handle_private_data(str)
        chan, action, data = Oj.load(str, {bigdecimal_load: :bigdecimal})
        m = {}
        case action
        when 'on'
          m[:event] = 'order_new'
          k = [:order_id, :pair, :amount, :original_amount, :type, :status, :price, :avg_price, :created_at]
        when 'ou'
          m[:event] = 'order_update'
          k = [:order_id, :pair, :amount, :original_amount, :type, :status, :price, :avg_price, :created_at]
        when 'oc'
          m[:event] = 'order_close'
          k = [:order_id, :pair, :amount, :original_amount, :type, :status, :price, :avg_price, :created_at]
        when 'te'
          m[:event] = 'trade_execute'
          k = [:order_id, :order_remaining_amount]
        when 'wu'
          m[:event] = 'wallet_update'
          k = [:name, :currency, :balance, :unsettled_interests]
        when 'pn'
          m[:event] = 'position_create'
          k = [:pair, :status, :amount, :base, :funding_price, :funding_type]
        when 'pu'
          m[:event] = 'position_update'
          k = [:pair, :status, :amount, :base, :funding_price, :funding_type]
        when 'pc'
          m[:event] = 'position_close'
          k = [:pair, :status, :amount, :base, :funding_price, :funding_type]
        when 'ps'
          m[:event] = 'position_status'
          k = [:pair, :status, :amount, :base, :funding_price, :funding_type]
          multiple = true
        when 'ws'
          m[:event] = 'wallet_status'
          k = [:name, :currency, :balance, :unsettled_interests]
          multiple = true
        when 'os'
          m[:event] = 'order_status'
          k = [:order_id, :pair, :amount, :original_amount, :type, :status, :price, :avg_price, :created_at]
          multiple = true
        end
        if k.nil? || data.to_a.length == 0
          m[:data] = []
        else
          if multiple
            m[:data] = data.collect!{ |d| Hash[k.zip(d)] }
          else
            m[:data] = Hash[k.zip(data)]
          end
        end
        @ws_client.call_handler(m[:event], m, str)
      end

      def handle_book_data(cid, data)
        m = {}
        if data['data_snapshot']
          k = [:price, :count, :amount]
          m[:chan_id] = cid
          m[:event] = 'book_snapshot'
          m[:data] = data['data_snapshot'].collect!{ |o| Hash[k.zip(o)] }
        else
          k = [:chan_id, :price, :count, :amount]
          m[:event] = 'book_update'
          m[:data] = Hash[k.zip(data['data'])]
        end
        @ws_client.call_handler(m[:event], m, data)
      end

      private

      def rubufy_pc_data(pc_data)
        tmparr = pc_data.split(',')
        chan_id = tmparr[0].gsub(/\[/, '').to_i
        if tmparr[0][0] == '['
          if tmparr[1][0] == '['
            ln = (tmparr[0].length+1).to_i
            valid_jsn = "{ \"data_snapshot\": #{pc_data[ln..-2]} }"
          else
            valid_jsn = "{ \"data\": #{pc_data} }"
          end
          return chan_id, Oj.load(valid_jsn, {bigdecimal_load: :bigdecimal})
        end
      end
    end
  end
end
