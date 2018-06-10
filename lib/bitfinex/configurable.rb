module Bitfinex
  module Configurable
    @config = nil
    def self.included(base)
    end

    def configure
      yield config
      self.load_submodules
    end

    private

    def config
      @config ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :api_endpoint, :debug, :debug_connection, :secret
    attr_accessor :api_key, :websocket_api_endpoint, :rest_timeout
    attr_accessor :reconnect, :reconnect_after, :rest_open_timeout
    attr_accessor :api_version

    def initialize
      self.api_endpoint = "https://api.bitfinex.com/v1/"
      self.websocket_api_endpoint = "wss://api.bitfinex.com/ws"
      self.debug = false
      self.reconnect = true
      self.reconnect_after = 60
      self.rest_timeout = 30
      self.rest_open_timeout = 30
      self.debug_connection = false
      self.api_version = 1
      self.secret = ENV['BITFINEX_API_SECRET']
      self.api_key = ENV['BITFINEX_API_KEY']
    end

    # Helper that configure to version 2
    def use_api_v2
      self.api_version = 2
      self.api_endpoint = "https://api.bitfinex.com/v2/"
      self.websocket_api_endpoint = "wss://api.bitfinex.com/ws/2/"
    end
  end
end
