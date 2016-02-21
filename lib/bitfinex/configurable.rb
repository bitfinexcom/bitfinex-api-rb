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
     attr_accessor :api_endpoint, :debug, :debug_connection, :secret, :api_key
     def initialize
       self.api_endpoint = "https://api.bitfinex.com/v1/"
       self.debug = false
       self.debug_connection = false
     end
  end

end
