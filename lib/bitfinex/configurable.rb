module Bitfinex
  module Configurable
    def self.included(base)
      base.extend(ClassMethods)
    end

    def config
      self.class.config
    end

    module ClassMethods
      def configure
        yield config
      end

      def config
        @configuration ||= Configuration.new
      end
    end
  end

  class Configuration
     attr_accessor :api_endpoint, :debug, :debug_connection, :secret, :api_key, :websocket_api_endpoint
     def initialize
       self.api_endpoint = "https://dev-prdn.bitfinex.com:2998/api/v1/"
       self.websocket_api_endpoint = "wss://api2.bitfinex.com:3000/ws"
       self.debug = false

       self.debug_connection = false
     end
  end

end
