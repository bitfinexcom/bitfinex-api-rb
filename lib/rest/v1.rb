# frozen_string_literal: true

require_relative './rest_client'
require_relative './v1/account_info'
require_relative './v1/deposit'
require_relative './v1/funding_book'
require_relative './v1/historical_data'
require_relative './v1/lends'
require_relative './v1/margin_funding'
require_relative './v1/order_book'
require_relative './v1/orders'
require_relative './v1/positions'
require_relative './v1/stats'
require_relative './v1/symbols'
require_relative './v1/ticker'
require_relative './v1/trades'
require_relative './v1/wallet'

module Bitfinex
  # RESTv1 API Interface
  class RESTv1
    # @return [String]
    attr_accessor :api_endpoint

    # @return [Boolean]
    attr_accessor :debug

    # @return [Boolean]
    attr_accessor :debug_connection

    # @return [Numeric]
    attr_accessor :api_version

    # @return [Numeric]
    attr_accessor :rest_timeout

    # @return [Numeric]
    attr_accessor :rest_open_timeout

    # @return [String]
    attr_accessor :proxy

    # @return [String]
    attr_accessor :api_key

    # @return [String]
    attr_accessor :api_secret

    include Bitfinex::RESTClient
    include Bitfinex::RESTv1AccountInfo
    include Bitfinex::RESTv1Deposit
    include Bitfinex::RESTv1FundingBook
    include Bitfinex::RESTv1HistoricalData
    include Bitfinex::RESTv1Lends
    include Bitfinex::RESTv1MarginFunding
    include Bitfinex::RESTv1OrderBook
    include Bitfinex::RESTv1Orders
    include Bitfinex::RESTv1Positions
    include Bitfinex::RESTv1Stats
    include Bitfinex::RESTv1Symbols
    include Bitfinex::RESTv1Ticker
    include Bitfinex::RESTv1Trades
    include Bitfinex::RESTv1Wallet

    # @param args [Hash]
    def initialize(args = {})
      self.api_endpoint = args[:url] ? "#{args[:url]}/v1/" : 'https://api.bitfinex.com/v1/'
      self.proxy = args[:proxy] || nil
      self.debug_connection = false
      self.api_version = 1
      self.rest_timeout = 30
      self.rest_open_timeout = 30
      self.api_key = args[:api_key]
      self.api_secret = args[:api_secret]
    end

    # @return [Hash]
    def config
      {
        api_endpoint: api_endpoint,
        debug_connection: debug_connection,
        api_version: api_version,
        rest_timeout: rest_timeout,
        rest_open_timeout: rest_open_timeout,
        proxy: proxy,
        api_key: api_key,
        api_secret: api_secret
      }
    end
  end
end
