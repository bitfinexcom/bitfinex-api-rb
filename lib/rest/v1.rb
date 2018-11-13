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
  class RESTv1
    attr_accessor :api_endpoint, :debug, :debug_connection, :api_version
    attr_accessor :rest_timeout, :rest_open_timeout, :proxy
    attr_accessor :api_key, :api_secret

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

    def initialize(args = {})
      self.api_endpoint = args[:url] ? "#{args[:url]}/v1/" : "https://api.bitfinex.com/v1/"
      self.proxy = args[:proxy] || nil
      self.debug_connection = false
      self.api_version = 1
      self.rest_timeout = 30
      self.rest_open_timeout = 30
      self.api_key = args[:api_key]
      self.api_secret = args[:api_secret]
    end

    def config
      {
        :api_endpoint => self.api_endpoint,
        :debug_connection => self.debug_connection,
        :api_version => self.api_version,
        :rest_timeout => self.rest_timeout,
        :rest_open_timeout => self.rest_open_timeout,
        :proxy => self.proxy,
        :api_key => self.api_key,
        :api_secret => self.api_secret
      }
    end
  end
end