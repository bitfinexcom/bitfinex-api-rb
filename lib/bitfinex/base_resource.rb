module Bitfinex
  class BaseResource
    class << self
      def set_properties *props
        @properties = props
        props.each do |val|
          class_eval %{
            def #{val}=(v);@#{val}=v;end
            def #{val};@#{val};end
          }
        end 
      end

      def properties
        @properties
      end
    end

    def initialize(obj)
      obj.each do |k,v|
        if self.class.properties.include?(k.to_sym)   
          send((k+'=').to_sym,v)
        end
      end
    end
  end
end
