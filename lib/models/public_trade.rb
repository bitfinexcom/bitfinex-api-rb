# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Public Trade model
    class PublicTrade < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        mts: 1,
        amount: 2,
        price: 3
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [Number] :mts
      # @option data [Number] :amount
      # @option data [Number] :price
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format public trade to a hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
