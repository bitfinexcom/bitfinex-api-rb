require_relative './model'

module Bitfinex
  module Models
    class TradingTicker < Model
      BOOL_FIELDS = []
      FIELDS = {
        bid: 0,
        bid_size: 1,
        ask: 2,
        ask_size: 3,
        daily_change: 4,
        daily_change_perc: 5,
        last_price: 6,
        volume: 7,
        high: 8,
        low: 9
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
