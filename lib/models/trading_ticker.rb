require_relative './model'

module Bitfinex
  module Models
    class TradingTicker < Model
      BOOL_FIELDS = []
      FIELDS = {
        symbol: 0,
        bid: 1,
        bid_size: 2,
        ask: 3,
        ask_size: 4,
        daily_change: 5,
        daily_change_perc: 6,
        last_price: 7,
        volume: 8,
        high: 9,
        low: 10
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
