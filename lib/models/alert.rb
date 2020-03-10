# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Price Alert model
    class Alert < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        key: 0,
        type: 1,
        symbol: 2,
        price: 3
      }.freeze

      FIELDS.each do |key|
        attr_accessor key
      end

      # @param data [Hash] - can also be an array
      # @option data [String] :key
      # @option data [String] :type
      # @option data [String] :symbol
      # @option data [Number] :price
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array Alert to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
