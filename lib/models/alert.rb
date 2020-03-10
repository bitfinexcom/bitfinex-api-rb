# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Price Alert model
    #
    # @attr [String] key
    class Alert < Model
      BOOL_FIELDS = [].freeze # @private

      FIELDS = {
        key: 0,
        type: 1,
        symbol: 2,
        price: 3
      }.freeze

      # @return [String]
      attr_accessor :key

      # @return [String]
      attr_accessor :type
      #
      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :price

      # @param data [Hash] - can also be an array
      # @option data [String] :key
      # @option data [String] :type
      # @option data [String] :symbol
      # @option data [Numeric] :price
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
