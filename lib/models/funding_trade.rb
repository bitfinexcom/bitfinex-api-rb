# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Funding Trade model
    class FundingTrade < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        symbol: 1,
        mts_create: 2,
        offer_id: 3,
        amount: 4,
        rate: 5,
        period: 6,
        maker: 7
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :mts_create

      # @return [Numeric]
      attr_accessor :offer_id

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :rate

      # @return [Numeric]
      attr_accessor :period

      # @return [Boolean]
      attr_accessor :maker

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :symbol
      # @option data [Numeric] :mts_create
      # @option data [Numeric] :offer_id
      # @option data [Numeric] :amount
      # @option data [Numeric] :rate
      # @option data [Numeric] :period
      # @option data [Numeric] :maker
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array funding trade to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
