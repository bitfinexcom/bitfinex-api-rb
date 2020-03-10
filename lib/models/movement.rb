# frozen_String_literal: true

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

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :currency

      # @return [String]
      attr_accessor :currency_name

      # @return [Numeric]
      attr_accessor :mts_started

      # @return [Numeric]
      attr_accessor :mts_updated

      # @return [String]
      attr_accessor :status

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :fees

      # @return [String]
      attr_accessor :destination_address

      # @return [String]
      attr_accessor :transaction_id

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :currency
      # @option data [String] :currency_name
      # @option data [Numeric] :mts_started
      # @option data [Numeric] :mts_updated
      # @option data [String] :status
      # @option data [Numeric] :amount
      # @option data [Numeric] :fees
      # @option data [String] :destination_address
      # @option data [Numeric] :transaction_id
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
