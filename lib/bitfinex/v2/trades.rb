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

  end
end
