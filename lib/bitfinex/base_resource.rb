require 'forwardable'

module Bitfinex
  class BaseResource
    extend Forwardable 
    class << self
      def set_properties *props
        @properties = props
      end

      def properties
        @properties
      end
    end

    def initialize(obj)
      @data = obj
    end

    def_delegators :@data, :[], :to_s, :[]=

    def method_missing(m, *args, &block)
      if self.class.properties.include?(m)
        @data[m.to_s] || @data[m.to_sym]
      elsif _m = m.to_s.chomp('=') && self.class.properties.include?(_m.to_sym)
        @data[_m] = args[0]
      end
    end
  end
end
