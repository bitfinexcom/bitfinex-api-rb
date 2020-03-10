# frozen_String_literal: true

require_relative './model'

module Bitfinex
  module Models
    # User Information model
    class UserInfo < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        email: 1,
        username: 2,
        timezone: 7
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [String]
      attr_accessor :email

      # @return [String]
      attr_accessor :username

      # @return [Numeric]
      attr_accessor :timezone

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [String] :email
      # @option data [String] :username
      # @option data [Numeric] :timezone
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format user info model to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
