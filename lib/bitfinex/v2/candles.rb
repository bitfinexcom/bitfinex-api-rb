# coding: utf-8

module Bitfinex
  module V2::CandlesClient

    # Provides a way to access charting candle info
    #
    # @param symbol [string] The symbol you want information about.
    # @param timeframe [string] Available values: '1m', '5m', '15m',
    #        '30m', '1h', '3h', '6h', '12h', '1D', '7D', '14D', '1M'
    # @param section [string] Available values: "last", "hist"
    # @param params :limit [int32] Number of candles requested
    # @param params :start [int32] Filter start (ms)
    # @param params :end [int32] Filter end (ms)
    # @param params :sort [int32] if = 1 it sorts
    #        results returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.candles('tBTCUSD')
    def candles(symbol = 'tBTCUSD', timeframe = '1m', section = "last", params = {})
      check_params(params, %i{limit start end sort})
      get("candles/trade:#{timeframe}:#{symbol}/#{section}", params).body
    end

  end
end
