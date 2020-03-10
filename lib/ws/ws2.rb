# frozen_string_literal: true

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
  # Implements version 2 of the Bitfinex WebSocket API, taking an evented
  # approach. Incoming packets trigger event broadcasts with names relevant to
  # the individual packets. Provides order manipulation methods that support
  # callback blocks, which are called when the relevant confirmation
  # notifications are received
  #
  # @example
  #   client = Bitfinex::WSv2.new({
  #     :url => ENV['WS_URL'],
  #     :api_key => ENV['API_KEY'],
  #     :api_secret => ENV['API_SECRET'],
  #     :transform => true, # provide models as event data instead of arrays
  #     :seq_audit => true, # enable and audit sequence numbers
  #     :manage_order_books => true, # allows for OB checksum verification
  #     :checksum_audit => true # enables OB checksum verification (needs manage_order_books)
  #   })
  #
  #   client.on(:open) do
  #     client.auth!
  #   end
  #
  #   client.on(:auth) do
  #     puts 'succesfully authenticated'
  #
  #     o = Bitfinex::Models::Order.new({
  #       :type => 'EXCHANGE LIMIT',
  #       :price => 3.0152235,
  #       :amount => 2.0235235263262,
  #       :symbol => 'tEOSUSD'
  #     })
  #
  #     client.submit_order(o)
  #   end
  #
  #   client.on(:notification) do |n|
  #     puts 'received notification: %s' % [n]
  #   end
  #
  #   client.on(:order_new) do |msg|
  #     puts 'recv order new: %s' % [msg]
  #   end
  #
  #   client.open!
  class WSv2 # rubocop:disable Metrics/ClassLength
    include Emittr::Events

    INFO_SERVER_RESTART = 20_051
    INFO_MAINTENANCE_START = 20_060
    INFO_MAINTENANCE_END = 20_061

    # enables all decimals as strings
    FLAG_DEC_S = 8

    # enables all timestamps as strings
    FLAG_TIME_S = 32

    # timestamps in milliseconds
    FLAG_TIMESTAMP = 32_768

    # enable sequencing
    FLAG_SEQ_ALL = 65_536

    # enable OB checksums, top 25 levels per side
    FLAG_CHECKSUM = 131_072

    # Creates a new instance of the class
    #
    # @param params [Hash]
    # @option params [String] :url connection URL
    # @option params.aff_code [String] :aff_code optional affiliate code to be
    #   applied to all orders
    #
    # @option params [String] :api_key
    # @option params [String] :api_secret
    # @option params [Boolean] :manage_order_books if true, order books are
    #   persisted internally, allowing for automatic checksum verification
    #
    # @option params [Boolean] :transform if true, full models are returned in
    #   place of array data
    #
    # @option params [Boolean] :seq_audit enables auto seq number verification
    # @option params [Boolean] :checksum_audit enables automatic OB checksum
    #   verification (requires manage_order_books)
    def initialize(params = {})
      @l = Logger.new(STDOUT)
      @l.progname = 'ws2'

      init_from_params(params)
      reset!
    end

    # @return [nil]
    # @private
    def reset!
      @enabled_flags = 0
      @is_open = false
      @is_authenticated = false
      @channel_map = {}
      @order_books = {}
      @pending_blocks = {}
      @last_pub_seq = nil
      @last_auth_seq = nil
    end

    # @param [Hash] params
    # @return [nil]
    # @private
    def init_from_params(params)
      @url = params[:url] || 'wss://api.bitfinex.com/ws/2'
      @aff_code = params[:aff_code]
      @manage_obs = params[:manage_order_books]
      @transform = !params[:transform].nil?
      @seq_audit = !params[:seq_audit].nil?
      @checksum_audit = !params[:checksum_audit].nil?
      api_credentials(params)
    end

    # @param [Hash] params
    # @option params [String] :api_key
    # @option params [String] :api_secret
    # @return [nil]
    def api_credentials(params)
      @api_key = params[:api_key]
      @api_secret = params[:api_secret]
      nil
    end

    # @return [nil]
    # @private
    def on_open
      @l.info 'client open'
      @is_open = true
      emit(:open)

      enable_sequencing if @seq_audit
      enable_ob_checksums if @checksum_audit
    end

    # @param event [Hash]
    # @return [nil]
    # @private
    def on_message(event)
      @l.info "recv #{event.data}"

      msg = JSON.parse(event.data)
      process_message(msg)

      emit(:message, msg)
    end

    # @return [nil]
    # @private
    def on_close
      @l.info 'client closed'
      @is_open = false
      emit(:close)
    end

    # Opens the websocket client inside an eventmachine run block
    #
    # @return [nil]
    def open!
      raise Exception, 'already open' if @is_open

      EM.run do
        @ws = Faye::WebSocket::Client.new(@url)

        @ws.on(:open) { |e| on_open(e) }
        @ws.on(:message) { |e| on_message(e) }
        @ws.on(:close) { |e| on_close(e) }
      end
    end

    # Closes the websocket client
    #
    # @return [nil]
    def close!
      @ws.close
    end

    # @param msg [Array]
    # @return [nil]
    # @private
    def process_message(msg)
      validate_message_seq(msg) if @seq_audit

      if msg.is_a?(Array)
        process_channel_message(msg)
      elsif msg.is_a?(Hash)
        process_event_message(msg)
      end
    end

    # @param msg [Array]
    # @return [nil]
    # @private
    def validate_message_seq(msg) # rubocop:disable all
      return unless @seq_audit
      return unless msg.is_a?(Array)
      return unless msg.size > 2

      # The auth sequence # is the last value in channel 0 non-hb packets
      if msg[0].zero? && msg[1] != 'hb' # rubocop:disable all
        auth_seq = msg[-1]
      else
        auth_seq = nil
      end

      # all other packets provide a public sequence # as the last value. For
      # chan 0 packets, these are included as the 2nd to last value
      #
      # note that error notifications lack seq
      if msg[0].zero? && msg[1] != 'hb' && !(msg[1] && msg[2][6] == 'ERROR') #rubocop:disable all
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
      return if auth_seq.zero?
      return if msg[1] == 'n' && msg[2][6] == 'ERROR' # error notifications
      return if auth_seq == @last_auth_seq # seq didn't advance

      if !@last_auth_seq.nil? && auth_seq != @last_auth_seq + 1
        @l.warn "invalid auth seq #; last #{@last_auth_seq}, got #{auth_seq}"
      end

      @last_auth_seq = auth_seq
    end

    # @param msg [Array]
    # @return [nil]
    # @private
    def process_channel_message(msg) # rubocop:disable all
      unless @channel_map.include?(msg[0])
        @l.error "recv message on unknown channel: #{msg[0]}"
        return
      end

      chan = @channel_map[msg[0]]
      type = msg[1]

      return if msg.size < 2 || type == 'hb'

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

    # @param msg [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_ticker_message(msg, chan)
      payload = transform_ticker_payload(msg[1], chan['symbol'])
      emit(:ticker, chan['symbol'], payload)
    end

    # @param data [Array]
    # @param symbol [String]
    # @return [nil]
    # @private
    def transform_ticker_payload(data, symbol)
      data_with_sym = [symbol].concat(data)

      if chan['symbol'][0] == 't'
        @transform ? Models::TradingTicker.new(data_with_sym) : data
      else
        @transform ? Models::FundingTicker.new(data_with_sym) : data
      end
    end

    # @param msg [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_trades_message(msg, chan)
      if msg[1].is_a?(Array)
        payload = msg[1]
        emit(
          :public_trades, chan['symbol'],
          @transform ? payload.map { |t| Models::PublicTrade.new(t) } : payload
        )
      else
        handle_single_trade_message(trade, chan)
      end
    end

    # @param trade [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_single_trade_message(trade, chan)
      payload = @transform ? Models::PublicTrade.new(trade[2]) : trade[2]
      type = trade[1]

      emit(:public_trades, chan['symbol'], payload)

      if type == 'te'
        emit(:public_trade_entry, chan['symbol'], payload)
      elsif type == 'tu'
        emit(:public_trade_update, chan['symbol'], payload)
      end
    end

    # @param msg [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_candles_message(msg, chan)
      emit(:candles, chan['key'], transform_candles_payload(msg[1]))
    end

    # @param data [Array<Array>, Array] single or multiple candles
    # @return [nil]
    def transform_candles_payload(data)
      if data[0].is_a?(Array)
        @transform ? data.map { |c| Models::Candle.new(c) } : data
      else
        @transform ? Models::Candle.new(data) : data
      end
    end

    # @param msg [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_order_book_checksum_message(msg, chan)
      key = "#{chan['symbol']}:#{chan['prec']}:#{chan['len']}"
      emit(:checksum, chan['symbol'], msg)

      return unless @manage_obs && @order_books.key?(key)

      remote_cs = msg[2]
      local_cs = @order_books[key].checksum

      if local_cs != remote_cs
        handle_order_book_checksum_error(local_cs, remote_cs, chan)
      else
        @l.info "OB checksum OK #{local_cs} [#{chan['symbol']}]"
      end
    end

    # @param local_cs [Number]
    # @param remote_cs [Number]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_order_book_checksum_error(local_cs, remote_cs, chan)
      err = format(
        'OB checksum mismatch, have %<local_cs>d want %<remote_cs>d [%<sym>s]',
        local_cs: local_cs, remote_cs: remote_cs, sym: chan['symbol']
      )

      @l.error err
      emit(:error, err)
    end

    # @param msg [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_order_book_message(msg, chan)
      ob = msg[1]

      if @manage_obs
        handle_managed_ob_update(ob, chan)
        data = @order_books[key]
      elsif @transform
        data = Models::OrderBook.new(ob)
      else
        data = ob
      end

      emit(:order_book, chan['symbol'], data)
    end

    # @param book [Array]
    # @param chan [Hash]
    # @return [nil]
    # @private
    def handle_managed_ob_update(book, chan)
      key = "#{chan['symbol']}:#{chan['prec']}:#{chan['len']}"

      if !@order_books.key?(key)
        @order_books[key] = Models::OrderBook.new(book, chan['prec'][0] == 'R')
      else
        @order_books[key].update_with(book)
      end
    end

    # Resolves/rejects any pending promise associated with the notification
    #
    # @param notification [Array]
    # @return [nil]
    # @private
    def handle_notification_promises(notification)
      payload = notification[4]
      return unless payload.is_a?(Array) # expect order payload

      case notification[1]
      when 'on-req'
        handle_new_order_notification_promises(notification)
      when 'oc-req'
        handle_closed_order_notification_promises(notification)
      when 'ou-req'
        handle_updated_order_notification_promises(notification)
      end
    end

    # @param notification [Array]
    # @return [nil]
    # @private
    def handle_updated_order_notification_promises(notification)
      k = "order-update-#{notification[4][0]}"

      return unless @pending_blocks.key?(k)

      call_pending_blocks_for_closed_order_notification(k, notification)
    end

    # @param key [String]
    # @param notification [Array]
    # @return [nil]
    # @private
    def call_pending_blocks_for_closed_order_notification(key, notification)
      if notification[6] == 'SUCCESS'
        @pending_blocks[key].call(
          @transform ? Models::Order.new(notification[4]) : notification[4]
        )
      else
        @pending_blocks[key].call(
          Exception.new("#{notification[6]}: #{notification[7]}")
        )
      end
    end

    # @param notification [Array]
    # @return [nil]
    # @private
    def handle_closed_order_notification_promises(notification)
      k = "order-cancel-#{notification[4][0]}"

      return unless @pending_blocks.key?(k)

      if notification[6] == 'SUCCESS'
        @pending_blocks[k].call(notification[4])
      else
        @pending_blocks[k].call(
          Exception.new("#{notification[6]}: #{notification[7]}")
        )
      end

      @pending_blocks.delete(k)
    end

    # @param notification [Array]
    # @return [nil]
    # @private
    def handle_new_order_notification_promises(notification)
      k = "order-new-#{notification[4][2]}"

      return unless @pending_blocks.key?(k)

      call_pending_blocks_for_new_order_notification(k, notification)
      @pending_blocks.delete(k)
    end

    # @param key [String] pending block key
    # @param notification [Array]
    # @return [nil]
    # @private
    def call_pending_blocks_for_new_order_notification(key, notification)
      if notification[6] == 'SUCCESS'
        @pending_blocks[key].call(
          @transform ? Models::Order.new(notification[4]) : notification[4]
        )
      else
        @pending_blocks[key].call(
          Exception.new("#{notification[6]}: #{notification[7]}")
        )
      end
    end

    # rubocop:disable all
    # @param msg [Hash]
    # @return [nil]
    # @private
    def handle_auth_message(msg)
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
        emit(:wallet_snapshot, @transform ? payload.map { Models::Wallet.new(payload) } : payload)
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
      emit(event_name)
    end
    # rubocop:enable all

    ###
    # Subscribes to the specified channel; params dictate the channel filter
    #
    # @param channel [string] i.e. 'trades', 'candles', etc
    # @param params [Hash]
    # @option params [string?] :symbol
    # @option params [string?] :prec for order book channels
    # @option params [string?] :len for order book channels
    # @option params [string?] :key for candle channels
    # @return [nil]
    ###
    def subscribe(channel, params = {})
      @l.info format(
        'subscribing to channel %<c>s [%<p>h]', c: channel, p: params
      )

      @ws.send(
        JSON.generate(params.merge({ event: 'subscribe', channel: channel }))
      )
    end

    ###
    # Subscribes to a ticker channel by symbol
    #
    # @param sym [string] i.e tBTCUSD
    # @return [nil]
    ###
    def subscribe_ticker(sym)
      subscribe('ticker', { symbol: sym })
    end

    ###
    # Subscribes to a trades channel by symbol
    #
    # @param sym [string] i.e tBTCUSD
    # @return [nil]
    ###
    def subscribe_trades(sym)
      subscribe('trades', { symbol: sym })
    end

    ###
    # Subscribes to a candle channel by key
    #
    # @param key [string] i.e. trade:1m:tBTCUSD
    # @return [nil]
    ###
    def subscribe_candles(key)
      subscribe('candles', { key: key })
    end

    ###
    # Subscribes to an order book channel
    #
    # @param sym [string] i.e. tBTCUSD
    # @param prec [string] i.e. R0, P0, etc
    # @param len [string] i.e. 25, 100, etc
    # @return [nil]
    ###
    def subscribe_order_book(sym, prec, len)
      subscribe('book', {
                  symbol: sym,
                  prec: prec,
                  len: len
                })
    end

    # @param msg [Hash]
    # @return [nil]
    # @private
    def process_event_message(msg) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
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

    # @param msg [Hash]
    # @return [nil]
    # @private
    def handle_auth_event(msg)
      if msg['status'] != 'OK'
        @l.error "auth failed: #{msg['message']}"
        return
      end

      @channel_map[msg['chanId']] = { 'channel' => 'auth' }
      @is_authenticated = true
      emit(:auth, msg)

      @l.info 'authenticated'
    end

    # @param msg [Hash]
    # @return [nil]
    # @private
    def handle_info_event(msg)
      if msg.include?('version')
        handle_info_version_event(msg)
      elsif msg.include?('code')
        handle_info_code_event(msg['code'])
      end
    end

    # @param msg [Hash]
    # @return [nil]
    # @private
    def handle_info_version_event(msg)
      handle_potential_version_mismatch(msg)
      status = msg['platform']['status']

      @l.info format(
        'server running API v2 (platform: %<str>s (%<status>d))', {
          str: status.zero? ? 'under maintenance' : 'operating normally',
          v: status
        }
      )
    end

    # @return [nil]
    # @private
    def handle_potential_version_mismatch
      return unless msg['version'] != 2

      close!
      raise Exception, "server not running API v2: #{msg['version']}"
    end

    # @param code [number]
    # @return [nil]
    # @private
    def handle_info_code_event(code)
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

    # @param [Hash] msg
    # @return [nil]
    # @private
    def handle_error_event(msg) # :nodoc:
      @l.error msg
      nil
    end

    # @param [Hash] msg
    # @return [nil]
    # @private
    def handle_config_event(msg)
      if msg['status'] != 'OK'
        @l.error "config failed: #{msg['message']}"
      else
        @l.info "flags updated to #{msg['flags']}"
        @enabled_flags = msg['flags']
      end
    end

    # @param msg [Hash]
    # @return [nil]
    # @private
    def handle_subscribed_event(msg)
      @l.info "subscribed to #{msg['channel']} [#{msg['chanId']}]"
      @channel_map[msg['chanId']] = msg
      emit(:subscribed, msg['chanId'])
    end

    # @param msg [Hash]
    # @return [nil]
    # @private
    def handle_unsubscribed_event(msg)
      @l.info "unsubscribed from #{msg['chanId']}"
      @channel_map.delete(msg['chanId'])
      emit(:unsubscribed, msg['chanId'])
    end

    # Enable an individual flag (see FLAG_* constants)
    #
    # @param flag [number]
    # @return [nil]
    def enable_flag(flag)
      return unless @is_open

      @ws.send(JSON.generate({
                               event: 'conf',
                               flags: @enabled_flags | flag
                             }))
    end

    # Checks if an individual flag is enabled (see FLAG_* constants)
    #
    # @param [number] flag
    # @return [boolean] enabled
    def is_flag_enabled(flag) # rubocop:disable Naming/PredicateName
      (@enabled_flags & flag) == flag
    end

    # Sets the flag to activate sequence numbers on incoming packets
    #
    # @param [boolean] audit - if true (default), incoming seq numbers will be
    #   checked for consistency
    # @return [nil]
    def enable_sequencing(audit = true)
      @seq_audit = audit
      enable_flag(FLAG_SEQ_ALL)
    end

    # Sets the flag to activate order book checksums. Managed order books are
    # required for automatic checksum audits.
    #
    # @param [boolean] audit - if true (default), incoming checksums will be
    #   compared to local checksums
    # @return [nil]
    def enable_ob_checksums(audit = true)
      @checksum_audit = audit
      enable_flag(FLAG_CHECKSUM)
    end

    # Authenticates the socket connection
    #
    # @param calc [number]
    # @param dms [number] dead man switch, active 4
    # @return [nil]
    def auth!(calc = 0, dms = 0) # rubocop:disable all
      raise Exception, 'already authenticated' if @is_authenticated

      auth_nonce = new_nonce
      auth_payload = "AUTH#{auth_nonce}#{auth_nonce}"
      sig = sign(auth_payload)

      @ws.send(JSON.generate({
                               event: 'auth',
                               apiKey: @api_key,
                               authSig: sig,
                               authPayload: auth_payload,
                               authNonce: auth_nonce,
                               dms: dms,
                               calc: calc
                             }))
    end

    # @return [Number]
    # @private
    def new_nonce
      (Time.now.to_f * 1000).floor.to_s
    end

    # @param [Hash] payload
    # @return [String]
    # @private
    def sign(payload) # :nodoc:
      OpenSSL::HMAC.hexdigest('sha384', @api_secret, payload)
    end

    # Requests a calculation to be performed
    # @see https://docs.bitfinex.com/v2/reference#ws-input-calc
    #
    # @param [Array] prefixes - i.e. ['margin_base']
    # @return [nil]
    def request_calc(prefixes)
      @ws.send(JSON.generate([0, 'calc', nil, prefixes.map { |p| [p] }]))
    end

    # Update an order with a changeset by ID
    #
    # @param changes [Hash] must contain ID
    # @param callback [Block] triggered on receipt of confirmation notification
    # @return [nil]
    def update_order(changes, &callback)
      id = changes[:id] || changes['id']
      @ws.send(JSON.generate([0, 'ou', nil, changes]))

      @pending_blocks["order-update-#{id}"] = callback unless callback.nil?
    end

    # Cancel an order by ID
    #
    # @param order [Hash|Array|Order|number] must contain or be ID
    # @param callback [Block] triggered on receipt of confirmation notification
    # @return [nil]
    def cancel_order(order, &callback) # rubocop:disable all
      return unless @is_authenticated

      if order.is_a?(Numeric)
        id = order
      elsif order.is_a?(Array)
        id = order[0]
      elsif order.instance_of?(Models::Order)
        id = order.id
      elsif order.is_a?(Hash)
        id = order[:id] || order['id']
      else
        raise Exception, 'tried to cancel order with invalid ID'
      end

      @ws.send(JSON.generate([0, 'oc', nil, { id: id }]))

      @pending_blocks["order-cancel-#{id}"] = callback unless callback.nil?
    end

    # Submit a new order
    #
    # @param [Hash|Array|Order] order
    # @param [Block] cb - triggered upon receipt of confirmation notification
    # @return [nil]
    def submit_order(order, &cb) # rubocop:disable all
      return unless @is_authenticated

      if order.is_a?(Array)
        packet = order
      elsif order.instance_of?(Models::Order)
        packet = order.to_new_order_packet
      elsif order.is_a?(Hash)
        packet = Models::Order.new(order).to_new_order_packet
      else
        raise Exception, 'tried to submit order of unkown type'
      end

      unless @aff_code.nil?
        packet[:meta] = {} unless packet[:meta]

        packet[:meta][:aff_code] = @aff_code
      end

      @ws.send(JSON.generate([0, 'on', nil, packet]))

      return unless packet.key?(:cid) && !cb.nil?

      @pending_blocks["order-new-#{packet[:cid]}"] = cb
    end
  end
end
