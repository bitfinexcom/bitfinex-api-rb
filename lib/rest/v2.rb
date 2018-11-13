require_relative './rest_client'
require_relative './v2/margin'
require_relative './v2/personal'
require_relative './v2/stats'
require_relative './v2/ticker'
require_relative './v2/trading'
require_relative './v2/utils'

module Bitfinex
  class RESTv2
    attr_accessor :api_endpoint, :debug, :debug_connection, :api_version
    attr_accessor :rest_timeout, :rest_open_timeout, :proxy
    attr_accessor :api_key, :api_secret

    include Bitfinex::RESTClient
    include Bitfinex::RESTv2Margin
    include Bitfinex::RESTv2Personal
    include Bitfinex::RESTv2Stats
    include Bitfinex::RESTv2Ticker
    include Bitfinex::RESTv2Trading
    include Bitfinex::RESTv2Utils

    def initialize(args = {})
      self.api_endpoint = args[:url] ? "#{args[:url]}/v2/" : "https://api.bitfinex.com/v2/"
      self.proxy = args[:proxy] || nil
      self.debug_connection = false
      self.api_version = 2
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