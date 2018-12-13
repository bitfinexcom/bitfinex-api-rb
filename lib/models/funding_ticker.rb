require_relative './model'

module Bitfinex
  module Models
    class FundingTicker < Model
      BOOL_FIELDS = []
      FIELDS = {
        symbol: 0,
        frr: 1,
        bid: 2,
        bid_size: 3,
        bid_period: 4,
        ask: 5,
        ask_size: 6,
        ask_period: 7,
        daily_change: 8,
        daily_change_perc: 9,
        last_price: 10,
        volume: 11,
        high: 12,
        low: 13
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
