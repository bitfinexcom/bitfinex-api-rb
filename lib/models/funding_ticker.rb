require_relative './model'

module Bitfinex
  module Models
    class FundingTicker < Model
      attr_accessor :symbol, :frr, :bid, :bid_period, :bid_size, :ask
      attr_accessor :ask_period, :ask_size, :daily_change, :daily_change_perc
      attr_accessor :last_price, :volume, :high, :low

      def initialize (data)
        super(data, {}, [])
      end

      def serialize ()
        [
          self.symbol,
          [
            self.frr, self.bid, self.bid_period, self.bid_size, self.ask,
            self.ask_period, self.ask_size, self.daily_change,
            self.daily_change_perc, self.last_price, self.volume, self.high,
            self.low
          ]
        ]
      end

      def self.unserialize (arr)
        symbol = arr[0]
        payload = arr[1]
        data = payload.kind_of?(Array) ? payload : arr.dup[1..-1]

        {
          :symbol => symbol,
          :frr => data[0],
          :bid => data[1],
          :bid_period => data[2],
          :bid_size => data[3],
          :ask => data[4],
          :ask_period => data[5],
          :ask_size => data[6],
          :daily_change => data[7],
          :daily_change_perc => data[8],
          :last_price => data[9],
          :volume => data[10],
          :high => data[11],
          :low => data[12]
        }
      end
    end
  end
end
