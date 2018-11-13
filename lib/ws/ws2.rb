require 'faye/websocket'
require 'eventmachine'
require 'logger'
require 'emittr'
require_relative '../models/order_book'

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

      @enabled_flags = 0
      @is_open = false
      @is_authenticated = false
      @channel_map = {}
      @order_books = {}
    end

    def on_open (e)
      @l.info 'client open'
      @is_open = true
      emit(:open)
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
      if msg.kind_of?(Array)
        process_channel_message(msg)
      elsif msg.kind_of?(Hash)
        process_event_message(msg)
      end
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
      emit(:ticker, chan['symbol'], msg)
    end

    def handle_trades_message (msg, chan)
      emit(:public_trades, chan['symbol'], msg)
    end

    def handle_candles_message (msg, chan)
      emit(:candles, chan['key'], msg)
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

      p chan

      if @manage_obs
        key = "#{chan['symbol']}:#{chan['prec']}:#{chan['len']}"

        if !@order_books.has_key?(key)
          @order_books[key] = Models::OrderBook.new(ob, chan['prec'][0] == 'R')
        else
          @order_books[key].update_with(ob)
        end

        data = @order_books[key]
      else
        data = ob
      end

      emit(:order_book, chan['symbol'], data)
    end

    def handle_auth_message (msg, chan)
      type = msg[1]
      return if type == 'hb'
      payload = msg[2]

      case type
      when 'n'
        emit(:notification, payload)
      when 'te'
        emit(:trade_entry, payload)
      when 'tu'
        emit(:trade_update, payload)
      when 'os'
        emit(:order_snapshot, payload)
      when 'ou'
        emit(:order_update, payload)
      when 'on'
        emit(:order_new, payload)
      when 'oc'
        emit(:order_close, payload)
      when 'ps'
        emit(:position_snapshot, payload)
      when 'pn'
        emit(:position_new, payload)
      when 'pu'
        emit(:position_update, payload)
      when 'pc'
        emit(:position_close, payload)
      when 'fos'
        emit(:funding_offer_snapshot, payload)
      when 'fon'
        emit(:funding_offer_new, payload)
      when 'fou'
        emit(:funding_offer_update, payload)
      when 'foc'
        emit(:funding_offer_close, payload)
      when 'fcs'
        emit(:funding_credit_snapshot, payload)
      when 'fcn'
        emit(:funding_credit_new, payload)
      when 'fcu'
        emit(:funding_credit_update, payload)
      when 'fcc'
        emit(:funding_credit_close, payload)
      when 'fls'
        emit(:funding_loan_snapshot, payload)
      when 'fln'
        emit(:funding_loan_new, payload)
      when 'flu'
        emit(:funding_loan_update, payload)
      when 'flc'
        emit(:funding_loan_close, payload)
      when 'ws'
        emit(:wallet_snapshot, payload)
      when 'wu'
        emit(:wallet_update, payload)
      when 'bu'
        emit(:balance_update, payload)
      when 'miu'
        emit(:margin_info_update, payload)
      when 'fiu'
        emit(:funding_info_update, payload)
      when 'fte'
        emit(:funding_trade_entry, payload)
      when 'ftu'
        emit(:funding_trade_update, payload)
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

    def sign(payload)
      OpenSSL::HMAC.hexdigest('sha384', @api_secret, payload)
    end
  end
end
