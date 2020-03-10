# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Funding Offer model
    class FundingOffer < Model
      BOOL_FIELDS = %w[notify hidden renew].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        symbol: 1,
        mts_create: 2,
        mts_update: 3,
        amount: 4,
        amount_orig: 5,
        type: 6,
        flags: 9,
        status: 10,
        rate: 14,
        period: 15,
        notify: 16,
        hidden: 17,
        renew: 19,
        rate_real: 20
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :mts_create

      # @return [Numeric]
      attr_accessor :mts_update

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :amount_orig

      # @return [String]
      attr_accessor :type

      # @return [Numeric]
      attr_accessor :flags

      # @return [String]
      attr_accessor :status

      # @return [Numeric]
      attr_accessor :rate

      # @return [Numeric]
      attr_accessor :period

      # @return [Boolean]
      attr_accessor :notify

      # @return [Boolean]
      attr_accessor :hidden

      # @return [Boolean]
      attr_accessor :renew

      # @return [Numeric]
      attr_accessor :rate_real

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :symbol
      # @option data [Numeric] :mts_create
      # @option data [Numeric] :mts_update
      # @option data [Numeric] :amount
      # @option data [Numeric] :amount_orig
      # @option data [String] :type
      # @option data [Numeric] :flags
      # @option data [String] :status
      # @option data [Numeric] :rate
      # @option data [Numeric] :period
      # @option data [Boolean] :notify
      # @option data [Boolean] :hidden
      # @option data [Boolean] :renew
      # @option data [Numeric] :rate_real
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array funding offer to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end

      # Returns a packet that can be used to create a new funding offer with
      # this instance's data (type, symbol, amount, rate, period, flags)
      #
      # @return [Hash]
      def to_new_order_packet
        data = {
          type: @type,
          symbol: @symbol,
          amount: BigDecimal(@amount, 8).to_s,
          rate: BigDecimal(@rate, 8).to_s,
          period: 2
        }

        data[:flags] = @flags unless @flags.nil?
        data
      end
    end
  end
end
