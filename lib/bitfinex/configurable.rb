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
     attr_accessor :api_endpoint
  end

end
