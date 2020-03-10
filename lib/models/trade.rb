# frozen_String_literal: true

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

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :mts_create

      # @return [Numeric]
      attr_accessor :order_id

      # @return [Numeric]
      attr_accessor :exec_amount

      # @return [Numeric]
      attr_accessor :exec_price

      # @return [String]
      attr_accessor :order_type

      # @return [Numeric]
      attr_accessor :order_price

      # @return [Numeric]
      attr_accessor :maker

      # @return [Numeric]
      attr_accessor :fee

      # @return [String]
      attr_accessor :fee_currency

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :symbol
      # @option data [Numeric] :mts_create
      # @option data [Numeric] :order_id
      # @option data [Numeric] :exec_amount
      # @option data [Numeric] :exec_price
      # @option data [String] :order_type
      # @option data [Numeric] :order_price
      # @option data [Numeric] :maker
      # @option data [Numeric] :fee
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
