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

    # The Order Books channel allow you to keep track of the state of the Bitfinex order book.
    # It is provided on a price aggregated basis, with customizable precision.
    # After receiving the response, you will receive a snapshot of the book,
    # followed by updates upon any changes to the book.
    #
    # @param symbol [string]
    # @param precision [string] Level of price aggregation (P0, P1, P2, P3, R0).
    #       (default P0) R0 is raw books - These are the most granular books.
    # @param frequency [string] Frequency of updates (F0, F1, F2, F3).
    #       F0=realtime / F1=2sec / F2=5sec / F3=10sec (default F0)
    # @param length [int] Number of price points ("25", "100") [default="25"]
    #
    # Documentation:
    #   https://docs.bitfinex.com/v2/reference#ws-public-order-books
    #   https://docs.bitfinex.com/v2/reference#ws-public-raw-order-books
    #
    # @example:
    #   client.listen_book("tBTCUSD") do |trade|
    #     puts "traded #{trade[2][2]} BTC for #{trade[2][3]} USD"
    #   end
    def listen_book(symbol="tBTCUSD", frequency="F0", length=25, precision="P0", &block)
      raise BlockMissingError unless block_given?
      register_channel symbol: symbol, channel: "book", prec: precision, freq: frequency, len: length, &block
    end
  end
end
