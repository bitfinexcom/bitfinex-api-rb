# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Funding Info model
    class FundingInfo < Model
      attr_accessor :symbol, :yield_loan, :yield_lend
      attr_accessor :duration_loan, :duration_lend

      # @param data [Hash]
      # @option data [String] :symbol
      # @option data [Number] :yield_loan
      # @option data [Number] :yield_lend
      # @option data [Number] :duration_loan
      # @option data [Number] :duration_lend
      def initialize(data)
        super(data, {}, [])
      end

      # Returns an array representation of the model instance
      #
      # @return [Array]
      def serialize
        [
          'sym',
          symbol,
          [
            yield_loan,
            yield_lend,
            duration_loan,
            duration_lend
          ]
        ]
      end

      # Convert array funding info to a Hash
      #
      # @param arr [Array]
      # @return [Hash]
      def self.unserialize(arr)
        symbol = arr[1]
        data = arr[2]

        {
          symbol: symbol,
          yield_loan: data[0],
          yield_lend: data[1],
          duration_loan: data[2],
          duration_lend: data[3]
        }
      end
    end
  end
end
