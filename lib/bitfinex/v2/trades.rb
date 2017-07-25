# coding: utf-8

module Bitfinex
  module V2::TradesClient

    # Trades endpoint includes all the pertinent details
    # of the trade, such as price, size and time.
    #
    # @param symbol [string] the name of the symbol
    # @param params :limit [int32] Number of records
    # @param params :start [int32] Millisecond start time
    # @param params :end   [int32] Millisecond end time
    # @param params :sort  [int32] if = 1 it sorts
    #     results returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.trades("tETHUSD")
    def trades(symbol="tBTCUSD", params={})
      check_params(params, %i{limit start end sort})
      get("trades/#{symbol}", params).body
    end

    # This channel sends a trade message whenever a trade occurs at Bitfinex.
    # It includes all the pertinent details of the trade, such as price, size and time.
    #
    # @param symbol [string]
    # @param block [Block] The code to be executed when a new ticker is sent by the server
    #
    # Documentation:
    #   https://docs.bitfinex.com/v2/reference#ws-public-trades
    #
    # @example:
    #   client.listen_trades("tBTCUSD") do |trade|
    #     puts "traded #{trade[2][2]} BTC for #{trade[2][3]} USD"
    #   end
    def listen_trades(symbol="tBTCUSD", &block)
      raise BlockMissingError unless block_given?
      register_channel symbol: symbol, channel: "trades", &block
    end
  end
end
