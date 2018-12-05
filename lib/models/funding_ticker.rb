require_relative './model'

module Bitfinex
  module Models
    class FundingTicker < Model
      BOOL_FIELDS = []
      FIELDS = {
        frr: 0,
        bid: 1,
        bid_size: 2,
        bid_period: 3,
        ask: 4,
        ask_size: 5,
        ask_period: 6,
        daily_change: 7,
        daily_change_perc: 8,
        last_price: 9,
        volume: 10,
        high: 11,
        low: 12
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
