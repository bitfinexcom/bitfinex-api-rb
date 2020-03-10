# frozen_String_literal: true

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

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :frr

      # @return [Numeric]
      attr_accessor :bid

      # @return [Numeric]
      attr_accessor :bid_size

      # @return [Numeric]
      attr_accessor :bid_period

      # @return [Numeric]
      attr_accessor :ask

      # @return [Numeric]
      attr_accessor :ask_size

      # @return [Numeric]
      attr_accessor :ask_period

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
      # @option data [Numeric] :frr
      # @option data [Numeric] :bid
      # @option data [Numeric] :bid_size
      # @option data [Numeric] :bid_period
      # @option data [Numeric] :ask
      # @option data [Numeric] :ask_size
      # @option data [Numeric] :ask_period
      # @option data [Numeric] :daily_change
      # @option data [Numeric] :daily_change_perc
      # @option data [Numeric] :last_price
      # @option data [Numeric] :volume
      # @option data [Numeric] :high
      # @option data [Numeric] :low
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
