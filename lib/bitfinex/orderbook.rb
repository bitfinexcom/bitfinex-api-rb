# coding: utf-8
module Bitfinex
  module OrderbookClient

    # Get the full order book
    #
    # @param symbol [string] 
    # @param params :limit_bids [int] (optional) Limit the number of bids returned. May be 0 in which case the array of bids is empty. Default 50.
    # @param params :limit_asks [int] (optional) Limit the number of asks returned. May be 0 in which case the array of asks is empty. Default 50.
    # @param params :group [0/1] (optional) If 1, orders are grouped by price in the orderbook. If 0, orders are not grouped and sorted individually. Default 1
    # @return [Hash] :bids [Array], :asks [Array]
    # @example:
    #   client.orderbook("btcusd")
    def orderbook(symbol="btcusd", params = {})
      check_params(params, %i{limit_bids limit_asks group})
      get("book/#{symbol}", params: params).body
    end


    # Get the order book changes using websocket
    # 
    # @param pair [string] 
    # @param prec [string] Level of price aggregation (P0, P1, P2, P3). The default is P0.
    # @param freq [string] Frequency of updates (F0, F1, F2, F3). F0=realtime / F1=2sec / F2=5sec / F3=10sec
    # @param len [int] Number of price points (“25”, “100”) [default=“25”]
    # @param block [Block] The code to be executed when a new order is submitted
    # @example:
    #    client.listen_book do |order|
    #      puts order.inspect
    #    end
    def listen_book(pair="BTCUSD", prec='P0', freq='F0',len=25, &block)
      raise BlockMissingError unless block_given?
      register_channel pair:pair, channel: 'book', prec: prec, freq: freq, len: len, &block
    end
  end
end
