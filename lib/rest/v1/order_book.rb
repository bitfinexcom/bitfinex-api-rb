module Bitfinex
  module RESTv1OrderBook
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
      get("book/#{symbol}", params).body
    end
  end
end
