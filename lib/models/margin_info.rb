# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Margin Info model
    class MarginInfo < Model
      # @return [Numeric]
      attr_accessor :user_pl

      # @return [Numeric]
      attr_accessor :user_swaps

      # @return [Numeric]
      attr_accessor :margin_balance

      # @return [Numeric]
      attr_accessor :margin_net

      # @return [String]
      attr_accessor :type

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :tradable_balance

      # @return [Numeric]
      attr_accessor :gross_balance

      # @return [Numeric]
      attr_accessor :buy

      # @return [Numeric]
      attr_accessor :sell

      # Use unserialize and serialize methods to manipulate margin infos
      #
      # @param data [Hash]
      def initialize(data)
        super(data, {}, [])
      end

      # Convert this instance to an array format model
      #
      # @return [Array]
      def serialize # rubocop:disable Metrics/MethodLength
        if type == 'base'
          [
            type,
            [
              user_pl,
              user_swaps,
              margin_balance,
              margin_net
            ]
          ]
        else
          [
            type,
            symbol,
            [
              tradable_balance,
              gross_balance,
              buy,
              sell
            ]
          ]
        end
      end

      # Convert an array format margin info to a Hash
      #
      # @param arr [Array]
      # @return [Hash]
      def self.unserialize(arr) # rubocop:disable Metrics/MethodLength
        type = arr[0]

        if type == 'base'
          payload = arr[1]

          {
            type: type,
            user_pl: payload[0],
            user_swaps: payload[1],
            margin_balance: payload[2],
            margin_net: payload[3]
          }
        else
          symbol = arr[1]
          payload = arr[2]

          {
            type: type,
            symbol: symbol,
            tradable_balance: payload[0],
            gross_balance: payload[1],
            buy: payload[2],
            sell: payload[3]
          }
        end
      end
    end
  end
end
