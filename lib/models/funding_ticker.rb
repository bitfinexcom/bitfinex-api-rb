# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Funding Ticker model
    class FundingTicker < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
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
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [String] :symbol
      # @option data [Number] :frr
      # @option data [Number] :bid
      # @option data [Number] :bid_size
      # @option data [Number] :bid_period
      # @option data [Number] :ask
      # @option data [Number] :ask_size
      # @option data [Number] :ask_period
      # @option data [Number] :daily_change
      # @option data [Number] :daily_change_perc
      # @option data [Number] :last_price
      # @option data [Number] :volume
      # @option data [Number] :high
      # @option data [Number] :low
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array funding ticker to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
