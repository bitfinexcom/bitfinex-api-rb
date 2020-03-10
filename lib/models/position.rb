# frozen_string_literal: true

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

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [String] :symbol
      # @option data [String] :status
      # @option data [Number] :amount
      # @option data [Number] :base_price
      # @option data [Number] :margin_funding
      # @option data [String] :margin_funding_type
      # @option data [Number] :pl
      # @option data [Number] :pl_perc
      # @option data [Number] :liquidation_price
      # @option data [Number] :leverage
      # @option data [Number] :id
      # @option data [Number] :mts_create
      # @option data [Number] :mts_update
      # @option data [String] :type
      # @option data [Number] :collateral
      # @option data [Number] :collateral_min
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
