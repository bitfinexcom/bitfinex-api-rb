require_relative './model'

module Bitfinex
  module Models
    class MarginInfo < Model
      attr_accessor :user_pl, :user_swaps, :margin_balance, :margin_net, :type
      attr_accessor :symbol, :tradable_balance, :gross_balance, :buy, :sell

      def initialize (data)
        super(data, {}, [])
      end

      def serialize ()
        if self.type == 'base'
          return [
            self.type,
            [
              self.user_pl,
              self.user_swaps,
              self.margin_balance,
              self.margin_net
            ]
          ]
        else
          return [
            self.type,
            self.symbol,
            [
              self.tradable_balance,
              self.gross_balance,
              self.buy,
              self.sell
            ]
          ]
        end
      end

      def self.unserialize (arr)
        type = arr[0]

        if type == 'base'
          payload = arr[1]

          return {
            :type => type,
            :user_pl => payload[0],
            :user_swaps => payload[1],
            :margin_balance => payload[2],
            :margin_net => payload[3]
          }
        else
          symbol = arr[1]
          payload = arr[2]

          return {
            :type => type,
            :symbol => symbol,
            :tradable_balance => payload[0],
            :gross_balance => payload[1],
            :buy => payload[2],
            :sell => payload[3]
          }
        end
      end
    end
  end
end
