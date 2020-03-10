# frozen_string_literal: true

require_relative './rest_client'
require_relative './v2/margin'
require_relative './v2/personal'
require_relative './v2/stats'
require_relative './v2/ticker'
require_relative './v2/trading'
require_relative './v2/utils'
require_relative './v2/orders'
require_relative './v2/wallet'
require_relative './v2/funding'
require_relative './v2/positions'

module Bitfinex
  # RESTv2 API Interface
  class RESTv2
    # @return [String]
    attr_accessor :api_endpoint

    # @return [Boolean]
    attr_accessor :no_close

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

    # @return [String]
    attr_accessor :aff_code

    include Bitfinex::RESTClient
    include Bitfinex::RESTv2Margin
    include Bitfinex::RESTv2Personal
    include Bitfinex::RESTv2Stats
    include Bitfinex::RESTv2Ticker
    include Bitfinex::RESTv2Trading
    include Bitfinex::RESTv2Utils
    include Bitfinex::RESTv2Orders
    include Bitfinex::RESTv2Wallet
    include Bitfinex::RESTv2Funding
    include Bitfinex::RESTv2Positions

    # @param args [Hash]
    def initialize(args = {})
      self.api_endpoint = args[:url] ? "#{args[:url]}/v2/" : 'https://api.bitfinex.com/v2/'
      self.proxy = args[:proxy] || nil
      self.debug_connection = false
      self.api_version = 2
      self.rest_timeout = 30
      self.rest_open_timeout = 30
      self.api_key = args[:api_key]
      self.api_secret = args[:api_secret]
      self.aff_code = args[:aff_code]
    end

    # @return [Hash]
    def config # rubocop:disable Metrics/MethodLength
      {
        api_endpoint: api_endpoint,
        debug_connection: debug_connection,
        api_version: api_version,
        rest_timeout: rest_timeout,
        rest_open_timeout: rest_open_timeout,
        proxy: proxy,
        api_key: api_key,
        api_secret: api_secret,
        aff_code: aff_code
      }
    end
  end
end
