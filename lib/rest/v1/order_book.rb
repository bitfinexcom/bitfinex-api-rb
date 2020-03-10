# frozen_string_literal: true

module Bitfinex
  # RESTv1 API order book methods
  module RESTv1OrderBook
    # Get the full order book
    #
    # @param symbol [string]
    # @param params [Hash]
    # @option params :limit_bids [int?] :limit_bids default 50
    # @option params :limit_asks [int?] :limit_asks default 50
    # @option params :group [number?] if 1 orders are group by price
    # @return [Hash] :bids [Array], :asks [Array]
    # @example:
    #   client.orderbook("btcusd")
    def orderbook(symbol = 'btcusd', params = {})
      check_params(params, %i[limit_bids limit_asks group])
      get("book/#{symbol}", params).body
    end
  end
end
