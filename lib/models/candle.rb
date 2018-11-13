require_relative './model'

module Bitfinex
  module Models
    class Candle < Model
      BOOL_FIELDS = []
      FIELDS = {
        :mts => 0,
        :open => 1,
        :close => 2,
        :high => 3,
        :low => 4,
        :volume => 5
      }

      FIELDS.each do |key, index|
        attr_accessor key
      end

      def initialize (data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      def self.unserialize (data)
        return Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
