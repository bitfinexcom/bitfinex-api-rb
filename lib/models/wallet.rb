# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Wallet model
    class Wallet < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        type: 0,
        currency: 1,
        balance: 2,
        unsettled_interest: 3,
        balance_available: 4
      }.freeze

      # @return [String]
      attr_accessor :type

      # @return [String]
      attr_accessor :currency

      # @return [Numeric]
      attr_accessor :balance

      # @return [Numeric]
      attr_accessor :unsettled_interest

      # @return [Numeric]
      attr_accessor :balance_available

      # @param data [Hash]
      # @option data [String] :type
      # @option data [String] :currency
      # @option data [Numeric] :balance
      # @option data [Numeric] :unsettled_interest
      # @option data [Numeric] :balance_available
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format wallet to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
