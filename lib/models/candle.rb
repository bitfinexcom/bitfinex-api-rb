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

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :mts
      # @option data [Number] :open
      # @option data [Number] :close
      # @option data [Number] :high
      # @option data [Number] :low
      # @option data [Number] :volume
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
