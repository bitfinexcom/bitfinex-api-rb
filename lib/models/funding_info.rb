require_relative './model'

module Bitfinex
  module Models
    class FundingInfo < Model
      attr_accessor :symbol, :yield_loan, :yield_lend
      attr_accessor :duration_loan, :duration_lend

      def initialize (data)
        super(data, {}, [])
      end

      def serialize ()
        [
          'sym',
          self.symbol,
          [
            self.yield_loan,
            self.yield_lend,
            self.duration_loan,
            self.duration_lend
          ]
        ]
      end

      def self.unserialize (arr)
        symbol = arr[1]
        data = arr[2]

        {
          :symbol => symbol,
          :yield_loan => data[0],
          :yield_lend => data[1],
          :duration_loan => data[2],
          :duration_lend => data[3]
        }
      end
    end
  end
end
