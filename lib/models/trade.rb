# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Trade model
    class Trade < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        symbol: 1,
        mts_create: 2,
        order_id: 3,
        exec_amount: 4,
        exec_price: 5,
        order_type: 6,
        order_price: 7,
        maker: 8,
        fee: 9,
        fee_currency: 10
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [String] :symbol
      # @option data [Number] :mts_create
      # @option data [Number] :order_id
      # @option data [Number] :exec_amount
      # @option data [Number] :exec_price
      # @option data [String] :order_type
      # @option data [Number] :order_price
      # @option data [Number] :maker
      # @option data [Number] :fee
      # @option data [String] :fee_currency
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format trade to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
