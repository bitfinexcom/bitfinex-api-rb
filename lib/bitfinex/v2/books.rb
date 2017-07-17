# coding: utf-8

module Bitfinex
  module V2::BooksClient

    # The Order Books channel allow you to keep track
    # of the state of the Bitfinex order book.
    # It is provided on a price aggregated basis,
    # with customizable precision.
    #
    #
    # @param symbol [string] The symbol you want
    #     information about. You can find the list of
    #     valid symbols by calling the /symbols
    #     endpoint.
    # @param precision [string] Level of price
    #     aggregation (P0, P1, P2, P3, R0)
    # @param params :len [int32] Number of price
    #     points ("25", "100")
    #
    # @return [Hash] :bids [Array], :asks [Array]
    #
    # @example:
    #   client.orderbook("btcusd")
    def books(symbol="btcusd", precision="P0", params = {})
      check_params(params, %i{len})
      get("book/#{symbol}/#{precision}", params: params).body
    end
  end
end
