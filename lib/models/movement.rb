# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Movement model
    class Movement < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        currency: 1,
        currency_name: 2,
        mts_started: 5,
        mts_updated: 6,
        status: 9,
        amount: 12,
        fees: 13,
        destination_address: 16,
        transaction_id: 20
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [String] :currency
      # @option data [String] :currency_name
      # @option data [Number] :mts_started
      # @option data [Number] :mts_updated
      # @option data [String] :status
      # @option data [Number] :amount
      # @option data [Number] :fees
      # @option data [String] :destination_address
      # @option data [Number] :transaction_id
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array format movement to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
