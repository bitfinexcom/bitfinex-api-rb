# frozen_String_literal: true

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

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :bid

      # @return [Numeric]
      attr_accessor :bid_size

      # @return [Numeric]
      attr_accessor :ask

      # @return [Numeric]
      attr_accessor :ask_size

      # @return [Numeric]
      attr_accessor :daily_change

      # @return [Numeric]
      attr_accessor :daily_change_perc

      # @return [Numeric]
      attr_accessor :last_price

      # @return [Numeric]
      attr_accessor :volume

      # @return [Numeric]
      attr_accessor :high

      # @return [Numeric]
      attr_accessor :low

      # @param data [Hash]
      # @option data [String] :symbol
      # @option data [Numeric] :bid
      # @option data [Numeric] :bid_size
      # @option data [Numeric] :ask
      # @option data [Numeric] :ask_size
      # @option data [Numeric] :daily_change
      # @option data [Numeric] :daily_change_perc
      # @option data [Numeric] :last_price
      # @option data [Numeric] :volume
      # @option data [Numeric] :high
      # @option data [Numeric] :low
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
