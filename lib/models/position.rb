# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Position model
    class Position < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        symbol: 0,
        status: 1,
        amount: 2,
        base_price: 3,
        margin_funding: 4,
        margin_funding_type: 5,
        pl: 6,
        pl_perc: 7,
        liquidation_price: 8,
        leverage: 9,
        # placeholder
        id: 11,
        mts_create: 12,
        mts_update: 13,
        # placeholder
        type: 15,
        # placeholder
        collateral: 17,
        callateral_min: 18,
        meta: 19
      }.freeze

      # @return [String]
      attr_accessor :symbol

      # @return [String]
      attr_accessor :status

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :base_price

      # @return [Numeric]
      attr_accessor :margin_funding

      # @return [String]
      attr_accessor :margin_funding_type

      # @return [Numeric]
      attr_accessor :pl

      # @return [Numeric]
      attr_accessor :pl_perc

      # @return [Numeric]
      attr_accessor :liquidation_price

      # @return [Numeric]
      attr_accessor :leverage

      # @return [Numeric]
      attr_accessor :id

      # @return [Numeric]
      attr_accessor :mts_create

      # @return [Numeric]
      attr_accessor :mts_update

      # @return [String]
      attr_accessor :type

      # @return [Numeric]
      attr_accessor :collateral

      # @return [Numeric]
      attr_accessor :collateral_min

      # @return [Hash, nil]
      attr_accessor :meta

      # @param data [Hash]
      # @option data [String] :symbol
      # @option data [String] :status
      # @option data [Numeric] :amount
      # @option data [Numeric] :base_price
      # @option data [Numeric] :margin_funding
      # @option data [String] :margin_funding_type
      # @option data [Numeric] :pl
      # @option data [Numeric] :pl_perc
      # @option data [Numeric] :liquidation_price
      # @option data [Numeric] :leverage
      # @option data [Numeric] :id
      # @option data [Numeric] :mts_create
      # @option data [Numeric] :mts_update
      # @option data [String] :type
      # @option data [Numeric] :collateral
      # @option data [Numeric] :collateral_min
      # @option data [Hash, nil] :meta
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format position to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
