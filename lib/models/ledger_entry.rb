# frozen_string_literal: true

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

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [String] :currency
      # @option data [Number] :mts
      # @option data [Number] :amount
      # @option data [Number] :balance
      # @option data [String] :description
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)

        spl = description.split('wallet')
        self.wallet = spl && spl[1] ? spl[1].trim : nil
      end

      # Convert an array format ledger entry to a Hash
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
