# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Ledger Entry class
    class LedgerEntry < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        currency: 1,
        mts: 3,
        amount: 5,
        balance: 6,
        description: 8,
        wallet: nil
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :currency

      # @return [Numeric]
      attr_accessor :mts

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :balance

      # @return [String]
      attr_accessor :description

      # @return [String]
      attr_accessor :wallet

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :currency
      # @option data [Numeric] :mts
      # @option data [Numeric] :amount
      # @option data [Numeric] :balance
      # @option data [String] :description
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)

        spl = description.split('wallet')

        return unless spl

        self.wallet = spl[1] ? spl[1].trim : nil
      end

      # Convert an array format ledger entry to a Hash
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
