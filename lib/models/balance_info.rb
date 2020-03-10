# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Balance Information model
    class BalanceInfo < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        amount: 0,
        amount_net: 1
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :amount
      # @option data [Number] :amount_net
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
       end

      # Convert array balance info to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
