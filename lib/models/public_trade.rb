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

      # @return [Numeric]
      attr_accessor :id

      # @return [Numeric]
      attr_accessor :mts

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :price

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [Numeric] :mts
      # @option data [Numeric] :amount
      # @option data [Numeric] :price
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
