# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Candle model
    class Candle < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        mts: 0,
        open: 1,
        close: 2,
        high: 3,
        low: 4,
        volume: 5
      }.freeze

      # @return [Numeric]
      attr_accessor :mts

      # @return [Numeric]
      attr_accessor :open

      # @return [Numeric]
      attr_accessor :close

      # @return [Numeric]
      attr_accessor :high

      # @return [Numeric]
      attr_accessor :low

      # @return [Numeric]
      attr_accessor :volume

      # @param data [Hash]
      # @option data [Numeric] :mts
      # @option data [Numeric] :open
      # @option data [Numeric] :close
      # @option data [Numeric] :high
      # @option data [Numeric] :low
      # @option data [Numeric] :volume
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array candle to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
