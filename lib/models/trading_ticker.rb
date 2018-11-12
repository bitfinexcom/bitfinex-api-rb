require_relative './model'

module Bitfinex
  module Models
    class TradingTicker < Model
      attr_accessor :symbol, :bid, :bid_size, :ask, :ask_size, :daily_change
      attr_accessor :daily_change_perc, :last_price, :volume, :high, :low

      def initialize (data)
        super(data, {}, [])
      end

      def serialize ()
        [
          self.symbol,
          [
            self.bid, self.bid_size, self.ask, self.ask_size, self.daily_change,
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
          :bid => data[0],
          :bid_size => data[1],
          :ask => data[2],
          :ask_size => data[3],
          :daily_change => data[4],
          :daily_change_perc => data[5],
          :last_price => data[6],
          :volume => data[7],
          :high => data[8],
          :low => data[9]
        }
      end
    end
  end
end
