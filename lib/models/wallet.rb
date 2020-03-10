# frozen_string_literal: true

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

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [String] :type
      # @option data [String] :currency
      # @option data [Number] :balance
      # @option data [Number] :unsettled_interest
      # @option data [Number] :balance_available
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
