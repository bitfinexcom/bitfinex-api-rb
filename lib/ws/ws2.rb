require 'faye/websocket'
require 'eventmachine'
require 'logger'
require 'emittr'

require_relative '../models/alert'
require_relative '../models/balance_info'
require_relative '../models/candle'
require_relative '../models/currency'
require_relative '../models/funding_credit'
require_relative '../models/funding_info'
require_relative '../models/funding_loan'
require_relative '../models/funding_offer'
require_relative '../models/funding_ticker'
require_relative '../models/funding_trade'
require_relative '../models/ledger_entry'
require_relative '../models/margin_info'
require_relative '../models/movement'
require_relative '../models/notification'
require_relative '../models/order_book'
require_relative '../models/order'
require_relative '../models/position'
require_relative '../models/public_trade'
require_relative '../models/trade'
require_relative '../models/trading_ticker'
require_relative '../models/user_info'
require_relative '../models/wallet'

module Bitfinex
  class WSv2
    include Emittr::Events

    INFO_SERVER_RESTART = 20051
    INFO_MAINTENANCE_START = 20060
    INFO_MAINTENANCE_END = 20061

    FLAG_DEC_S = 8,         # enables all decimals as strings
    FLAG_TIME_S = 32,       # enables all timestamps as strings
    FLAG_TIMESTAMP = 32768, # timestamps in milliseconds
    FLAG_SEQ_ALL = 65536,   # enable sequencing
    FLAG_CHECKSUM = 131072  # enable OB checksums, top 25 levels per side

    def initialize (params = {})
      @l = Logger.new(STDOUT)
      @l.progname = 'ws2'

      @url = params[:url] || 'wss://api.bitfinex.com/ws/2'
      @api_key = params[:api_key]
      @api_secret = params[:api_secret]
      @manage_obs = params[:manage_order_books]
      @transform = !!params[:transform]
      @seq_audit = !!params[:seq_audit]
      @checksum_audit = !!params[:checksum_audit]

      @enabled_flags = 0
      @is_open = false
      @is_authenticated = false
      @channel_map = {}
      @order_books = {}
      @pending_blocks = {}
      @last_pub_seq = nil
      @last_auth_seq = nil
    end

    def on_open (e)
      @l.info 'client open'
      @is_open = true
      emit(:open)

      enable_sequencing if @seq_audit
      enable_ob_checksums if @checksum_audit
    end

    def on_message (e)
      @l.info "recv #{e.data}"

      msg = JSON.parse(e.data)
      process_message(msg)

      emit(:message, msg)
    end

    def on_close (e)
      @l.info 'client closed'
      @is_open = false
      emit(:close)
    end

    def open!
      if @is_open
        raise Exception, 'already open'
      end

      EM.run {
        @ws = Faye::WebSocket::Client.new(@url)

        @ws.on(:open) do |e|
          on_open(e)
        end

        @ws.on(:message) do |e|
          on_message(e)
        end

        @ws.on(:close) do |e|
          on_close(e)
        end
      }
    end

    def close!
      @ws.close
    end

    def process_message (msg)
      if @seq_audit
        validate_message_seq(msg)
      end

      if msg.kind_of?(Array)
        process_channel_message(msg)
      elsif msg.kind_of?(Hash)
        process_event_message(msg)
      end
    end

    def validate_message_seq (msg)
      return unless @seq_audit
      return unless msg.kind_of?(Array)
      return unless msg.size > 2

      # The auth sequence # is the last value in channel 0 non-hb packets
      if msg[0] == 0 && msg[1] != 'hb'
        auth_seq = msg[-1]
      else
        auth_seq = nil
      end

      # all other packets provide a public sequence # as the last value. For
      # chan 0 packets, these are included as the 2nd to last value
      #
      # note that error notifications lack seq
      if msg[0] == 0 && msg[1] != 'hb' && !(msg[1] && msg[2][6] == 'ERROR')
        pub_seq = msg[-2]
      else
        pub_seq = msg[-1]
      end

      return unless pub_seq.is_a?(Numeric)

      if @last_pub_seq.nil?
        @last_pub_seq = pub_seq
        return
      end

      if pub_seq != (@last_pub_seq + 1) # check pub seq
        @l.warn "invalid pub seq #; last #{@last_pub_seq}, got #{pub_seq}"
      end

      @last_pub_seq = pub_seq

      return unless auth_seq.is_a?(Numeric)
      return if auth_seq == 0
      return if msg[1] == 'n' && msg[2][6] == 'ERROR' # error notifications
      return if auth_seq == @last_auth_seq # seq didn't advance

      if !@last_auth_seq.nil? && auth_seq != @last_auth_seq + 1
        @l.warn "invalid auth seq #; last #{@last_auth_seq}, got #{auth_seq}"
      end

      @last_auth_seq = auth_seq
    end

    def process_channel_message (msg)
      if !@channel_map.include?(msg[0])
        @l.error "recv message on unknown channel: #{msg[0]}"
        return
      end

      chan = @channel_map[msg[0]]
      type = msg[1]

      if msg.size < 2 || type == 'hb'
        return
      end

      case chan['channel']
      when 'ticker'
        handle_ticker_message(msg, chan)
      when 'trades'
        handle_trades_message(msg, chan)
      when 'candles'
        handle_candles_message(msg, chan)
      when 'book'
        if type == 'cs'
          handle_order_book_checksum_message(msg, chan)
        else
          handle_order_book_message(msg, chan)
        end
      when 'auth'
        handle_auth_message(msg, chan)
      end
    end

    def handle_ticker_message (msg, chan)
      payload = msg[1]

      if chan['symbol'][0] === 't'
        emit(:ticker, chan['symbol'], @transform ? Models::TradingTicker.new(payload) : payload)
      else
        emit(:ticker, chan['symbol'], @transform ? Models::FundingTicker.new(payload) : payload)
      end
    end

    def handle_trades_message (msg, chan)
      if msg[1].kind_of?(Array)
        payload = msg[1]
        emit(:public_trades, chan['symbol'], @transform ? payload.map { |t| Models::PublicTrade.new(t) } : payload)
      else
        payload = @transform ? Models::PublicTrade.new(msg[2]) : msg[2]
        type = msg[1]

        emit(:public_trades, chan['symbol'], payload)

        if type == 'te'
          emit(:public_trade_entry, chan['symbol'], payload)
        elsif type == 'tu'
          emit(:public_trade_update, chan['symbol'], payload)
        end
      end
    end

    def handle_candles_message (msg, chan)
      payload = msg[1]

      if payload[0].kind_of?(Array)
        emit(:candles, chan['key'], @transform ? payload.map { |c| Models::Candle.new(c) } : payload)
      else
        emit(:candles, chan['key'], @transform ? Models::Candle.new(payload) : payload)
      end
    end

    def handle_order_book_checksum_message (msg, chan)
      key = "#{chan['symbol']}:#{chan['prec']}:#{chan['len']}"
      emit(:checksum, chan['symbol'], msg)

      return unless @manage_obs
      return unless @order_books.has_key?(key)

      remote_cs = msg[2]
      local_cs = @order_books[key].checksum

      if local_cs != remote_cs
        err = "OB checksum mismatch, have #{local_cs} want #{remote_cs} [#{chan['symbol']}"
        @l.error err
        emit(:error, err)
      else
        @l.info "OB checksum OK #{local_cs} [#{chan['symbol']}]"
      end
    end

    def handle_order_book_message (msg, chan)
      ob = msg[1]

      if @manage_obs
        key = "#{chan['symbol']}:#{chan['prec']}:#{chan['len']}"

        if !@order_books.has_key?(key)
          @order_books[key] = Models::OrderBook.new(ob, chan['prec'][0] == 'R')
        else
          @order_books[key].update_with(ob)
        end

        data = @order_books[key]
      elsif @transform
        data = Models::OrderBook.new(ob)
      else
        data = ob
      end

      emit(:order_book, chan['symbol'], data)
    end

    # Resolves/rejects any pending promise associated with the notification
    def handle_notification_promises (n)
      type = n[1]
      payload = n[4]
      status = n[6]
      msg = n[7]

      return unless payload.kind_of?(Array) # expect order payload

      case type
      when 'on-req'
        cid = payload[2]
        k = "order-new-#{cid}"

        return unless @pending_blocks.has_key?(k)

        if status == 'SUCCESS'
          @pending_blocks[k].call(@transform ? Models::Order.new(payload) : payload)
        else
          @pending_blocks[k].call(Exception.new("#{status}: #{msg}"))
        end

        @pending_blocks.delete(k)
      when 'oc-req'
        id = payload[0]
        k = "order-cancel-#{id}"

        return unless @pending_blocks.has_key?(k)

        if status == 'SUCCESS'
          @pending_blocks[k].call(payload)
        else
          @pending_blocks[k].call(Exception.new("#{status}: #{msg}"))
        end

        @pending_blocks.delete(k)
      when 'ou-req'
        id = payload[0]
        k = "order-update-#{id}"

        return unless @pending_blocks.has_key?(k)

        if status == 'SUCCESS'
          @pending_blocks[k].call(@transform ? Models::Order.new(payload) : payload)
        else
          @pending_blocks[k].call(Exception.new("#{status}: #{msg}"))
        end
      end
    end

    def handle_auth_message (msg, chan)
      type = msg[1]
      return if type == 'hb'
      payload = msg[2]

      case type
      when 'n'
        emit(:notification, @transform ? Models::Notification.new(payload) : payload)
        handle_notification_promises(payload)
      when 'te'
        emit(:trade_entry, @transform ? Models::Trade.new(payload) : payload)
      when 'tu'
        emit(:trade_update, @transform ? Models::Trade.new(payload) : payload)
      when 'os'
        emit(:order_snapshot, @transform ? payload.map { |o| Models::Order.new(o) } : payload)
      when 'ou'
        emit(:order_update, @transform ? Models::Order.new(payload) : payload)
      when 'on'
        emit(:order_new, @transform ? Models::Order.new(payload) : payload)
      when 'oc'
        emit(:order_close, @transform ? Models::Order.new(payload) : payload)
      when 'ps'
        emit(:position_snapshot, @transform ? payload.map { |p| Models::Position.new(p) } : payload)
      when 'pn'
        emit(:position_new, @transform ? Models::Position.new(payload) : payload)
      when 'pu'
        emit(:position_update, @transform ? Models::Position.new(payload) : payload)
      when 'pc'
        emit(:position_close, @transform ? Models::Position.new(payload) : payload)
      when 'fos'
        emit(:funding_offer_snapshot, @transform ? payload.map { |fo| Models::FundingOffer.new(fo) } : payload)
      when 'fon'
        emit(:funding_offer_new, @transform ? Models::FundingOffer.new(payload) : payload)
      when 'fou'
        emit(:funding_offer_update, @transform ? Models::FundingOffer.new(payload) : payload)
      when 'foc'
        emit(:funding_offer_close, @transform ? Models::FundingOffer.new(payload) : payload)
      when 'fcs'
        emit(:funding_credit_snapshot, @transform ? payload.map { |fc| Models::FundingCredit.new(fc) } : payload)
      when 'fcn'
        emit(:funding_credit_new, @transform ? Models::FundingCredit.new(payload) : payload)
      when 'fcu'
        emit(:funding_credit_update, @transform ? Models::FundingCredit.new(payload) : payload)
      when 'fcc'
        emit(:funding_credit_close, @transform ? Models::FundingCredit.new(payload) : payload)
      when 'fls'
        emit(:funding_loan_snapshot, @transform ? payload.map { |fl| Models::FundingLoan.new(fl) } : payload)
      when 'fln'
        emit(:funding_loan_new, @transform ? Models::FundingLoan.new(payload) : payload)
      when 'flu'
        emit(:funding_loan_update, @transform ? Models::FundingLoan.new(payload) : payload)
      when 'flc'
        emit(:funding_loan_close, @transform ? Models::FundingLoan.new(payload) : payload)
      when 'ws'
        emit(:wallet_snapshot, @transform ? payload.map { |w| Models::Wallet.new(payload) } : payload)
      when 'wu'
        emit(:wallet_update, @transform ? Models::Wallet.new(payload) : payload)
      when 'bu'
        emit(:balance_update, @transform ? Models::BalanceInfo.new(payload) : payload)
      when 'miu'
        emit(:margin_info_update, @transform ? Models::MarginInfo.new(payload) : payload)
      when 'fiu'
        emit(:funding_info_update, @transform ? Models::FundingInfo.new(payload) : payload)
      when 'fte'
        emit(:funding_trade_entry, @transform ? Models::FundingTrade.new(payload) : payload)
      when 'ftu'
        emit(:funding_trade_update, @transform ? Models::FundingTrade.new(payload) : payload)
      end
    end

    def subscribe (channel, params = {})
      @l.info 'subscribing to channel %s [%s]' % [channel, params]
      @ws.send(JSON.generate(params.merge({
        :event => 'subscribe',
        :channel => channel,
      })))
    end

    def subscribe_ticker (sym)
      subscribe('ticker', { :symbol => sym })
    end

    def subscribe_trades (sym)
      subscribe('trades', { :symbol => sym })
    end

    def subscribe_candles (key)
      subscribe('candles', { :key => key })
    end

    def subscribe_order_book (sym, prec, len)
      subscribe('book', {
        :symbol => sym,
        :prec => prec,
        :len => len
      })
    end

    def process_event_message (msg)
      case msg['event']
      when 'auth'
        handle_auth_event(msg)
      when 'subscribed'
        handle_subscribed_event(msg)
      when 'unsubscribed'
        handle_unsubscribed_event(msg)
      when 'info'
        handle_info_event(msg)
      when 'conf'
        handle_config_event(msg)
      when 'error'
        handle_error_event(msg)
      end
    end

    def handle_auth_event (msg)
      if msg['status'] != 'OK'
        @l.error "auth failed: #{msg['message']}"
        return
      end

      @channel_map[msg['chanId']] = { 'channel' => 'auth' }
      @is_authenticated = true
      emit(:auth, msg)

      @l.info 'authenticated'
    end

    def handle_info_event (msg)
      if msg.include?('version')
        if msg['version'] != 2
          close!
          raise Exception, "server not running API v2: #{msg['version']}"
        end

        platform = msg['platform']

        @l.info "server running API v2 (platform: %s (%d))" % [
          platform['status'] == 0 ? 'under maintenance' : 'operating normally',
          platform['status']
        ]
      elsif msg.include?('code')
        code = msg['code']

        if code == INFO_SERVER_RESTART
          @l.info 'server restarted, please reconnect'
          emit(:server_restart)
        elsif code == INFO_MAINTENANCE_START
          @l.info 'server maintenance period started!'
          emit(:maintenance_start)
        elsif code == INFO_MAINTENANCE_END
          @l.info 'server maintenance period ended!'
          emit(:maintenance_end)
        end
      end
    end

    def handle_error_event (msg)
      @l.error msg
    end

    def handle_config_event (msg)
      if msg['status'] != 'OK'
        @l.error "config failed: #{msg['message']}"
      else
        @l.info "flags updated to #{msg['flags']}"
        @enabled_flags = msg['flags']
      end
    end

    def handle_subscribed_event (msg)
      @l.info "subscribed to #{msg['channel']} [#{msg['chanId']}]"
      @channel_map[msg['chanId']] = msg
      emit(:subscribed, msg['chanId'])
    end

    def handle_unsubscribed_event (msg)
      @l.info "unsubscribed from #{msg['chanId']}"
      @channel_map.delete(msg['chanId'])
      emit(:unsubscribed, msg['chanId'])
    end

    def enable_flag (flag)
      return unless @is_open

      @ws.send(JSON.generate({
        :event => 'conf',
        :flags => @enabled_flags | flag
      }))
    end

    def is_flag_enabled (flag)
      (@enabled_flags & flag) == flag
    end

    def enable_sequencing (audit = true)
      @seq_audit = audit
      enable_flag(FLAG_SEQ_ALL)
    end

    def enable_ob_checksums
      enable_flag(FLAG_CHECKSUM)
    end

    def auth! (calc = 0, dms = 0)
      if @is_authenticated
        raise Exception, 'already authenticated'
      end

      auth_nonce = new_nonce
      auth_payload = "AUTH#{auth_nonce}#{auth_nonce}"
      sig = sign(auth_payload)

      @ws.send(JSON.generate({
        :event => 'auth',
        :apiKey => @api_key,
        :authSig => sig,
        :authPayload => auth_payload,
        :authNonce => auth_nonce,
        :dms => dms,
        :calc => calc
      }))
    end

    def new_nonce
      Time.now.to_i.to_s
    end

    def sign (payload)
      OpenSSL::HMAC.hexdigest('sha384', @api_secret, payload)
    end

    def request_calc (prefixes)
      @ws.send(JSON.generate([0, 'calc', nil, prefixes.map { |p| [p] }]))
    end

    def update_order (changes, &cb)
      id = changes[:id] || changes['id']
      @ws.send(JSON.generate([0, 'ou', nil, changes]))

      if !cb.nil?
        @pending_blocks["order-update-#{id}"] = cb
      end
    end

    def cancel_order (order, &cb)
      return if !@is_authenticated

      if order.is_a?(Numeric)
        id = order
      elsif order.is_a?(Array)
        id = order[0]
      elsif order.instance_of?(Models::Order)
        id = order.id
      elsif order.kind_of?(Hash)
        id = order[:id] || order['id']
      else
        raise Exception, 'tried to cancel order with invalid ID'
      end

      @ws.send(JSON.generate([0, 'oc', nil, { :id => id }]))

      if !cb.nil?
        @pending_blocks["order-cancel-#{id}"] = cb
      end
    end

    def submit_order (order, &cb)
      return if !@is_authenticated

      if order.kind_of?(Array)
        packet = order
      elsif order.instance_of?(Models::Order)
        packet = order.to_new_order_packet
      elsif order.kind_of?(Hash)
        packet = Models::Order.new(order).to_new_order_packet
      else
        raise Exception, 'tried to submit order of unkown type'
      end

      @ws.send(JSON.generate([0, 'on', nil, packet]))

      if packet.has_key?(:cid) && !cb.nil?
        @pending_blocks["order-new-#{packet[:cid]}"] = cb
      end
    end
  end
end
