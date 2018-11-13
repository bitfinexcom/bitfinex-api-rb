require_relative './model'

module Bitfinex
  module Models
    class Trade < Model
      BOOL_FIELDS = []
      FIELDS = {
        id: 0,
        symbol: 1,
        mts_create: 2,
        order_id: 3,
        exec_amount: 4,
        exec_price: 5,
        order_type: 6,
        order_price: 7,
        maker: 8,
        fee: 9,
        fee_currency: 10
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
