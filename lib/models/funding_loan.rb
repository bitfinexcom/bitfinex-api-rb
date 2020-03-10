# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Funding Loan model
    class FundingLoan < Model
      BOOL_FIELDS = %w[notify hidden renew no_close].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        symbol: 1,
        side: 2,
        mts_create: 3,
        mts_update: 4,
        amount: 5,
        flags: 6,
        status: 7,
        rate: 11,
        period: 12,
        mts_opening: 13,
        mts_last_payout: 14,
        notify: 15,
        hidden: 16,
        renew: 18,
        rate_real: 19,
        no_close: 20
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [String] :symbol
      # @option data [String] :side
      # @option data [Number] :mts_create
      # @option data [Number] :mts_update
      # @option data [Number] :amount
      # @option data [Number] :flags
      # @option data [String] :status
      # @option data [Number] :rate
      # @option data [Number] :period
      # @option data [Number] :mts_opening
      # @option data [Number] :mts_last_payout
      # @option data [Boolean] :notify
      # @option data [Boolean] :hidden
      # @option data [Boolean] :renew
      # @option data [Number] :rate_real
      # @option data [Boolean] :no_close
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array funding loan to a Hash
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
