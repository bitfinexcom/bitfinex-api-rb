# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Currency information model
    class Currency < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        name: 1,
        pool: 2,
        explorer: 3
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :name

      # @return [String]
      attr_accessor :pool

      # @return [String]
      attr_accessor :explorer

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :name
      # @option data [String] :pool
      # @option data [String] :explorer
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert array currency to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
