# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Funding Credit model
    class FundingCredit < Model
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
        no_close: 20,
        position_pair: 21
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :side

      # @return [Numeric]
      attr_accessor :mts_create

      # @return [Numeric]
      attr_accessor :mts_update

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :flags

      # @return [String]
      attr_accessor :status

      # @return [Numeric]
      attr_accessor :rate

      # @return [Numeric]
      attr_accessor :period

      # @return [Numeric]
      attr_accessor :mts_opening

      # @return [Numeric]
      attr_accessor :mts_last_payout

      # @return [Boolean]
      attr_accessor :notify

      # @return [Boolean]
      attr_accessor :hidden

      # @return [Boolean]
      attr_accessor :renew

      # @return [Numeric]
      attr_accessor :rate_real

      # @return [Boolean]
      attr_accessor :no_close

      # @return [String]
      attr_accessor :position_pair

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :symbol
      # @option data [String] :side
      # @option data [Numeric] :mts_create
      # @option data [Numeric] :mts_update
      # @option data [Numeric] :amount
      # @option data [Numeric] :flags
      # @option data [String] :status
      # @option data [Numeric] :rate
      # @option data [Numeric] :period
      # @option data [Numeric] :mts_opening
      # @option data [Numeric] :mts_last_payout
      # @option data [Boolean] :notify
      # @option data [Boolean] :hidden
      # @option data [Boolean] :renew
      # @option data [Numeric] :rate_real
      # @option data [Boolean] :no_close
      # @option data [String] :position_pair
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array funding credit to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
