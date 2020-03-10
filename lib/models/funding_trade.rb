# frozen_string_literal: true

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

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [String] :symbol
      # @option data [Number] :mts_create
      # @option data [Number] :offer_id
      # @option data [Number] :amount
      # @option data [Number] :rate
      # @option data [Number] :period
      # @option data [Number] :maker
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
