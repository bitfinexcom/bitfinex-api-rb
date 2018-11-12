require_relative './model'

module Bitfinex
  module Models
    class Position < Model
      BOOL_FIELDS = []
      FIELDS = {
        :symbol => 0,
        :status => 1,
        :amount => 2,
        :base_price => 3,
        :margin_funding => 4,
        :margin_funding_type => 5,
        :pl => 6,
        :pl_perc => 7,
        :liquidation_price => 8,
        :leverage => 9
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
