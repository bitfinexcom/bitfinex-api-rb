# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Trading Ticker model
    class TradingTicker < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
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
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [String] :symbol
      # @option data [Number] :bid
      # @option data [Number] :bid_size
      # @option data [Number] :ask
      # @option data [Number] :ask_size
      # @option data [Number] :daily_change
      # @option data [Number] :daily_change_perc
      # @option data [Number] :last_price
      # @option data [Number] :volume
      # @option data [Number] :high
      # @option data [Number] :low
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format trading ticker to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
