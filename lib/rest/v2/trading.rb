module Bitfinex
  module RESTv2Trading

    # Provides a way to access charting candle info
    #
    # @param symbol [string] The symbol you want information about.
    # @param timeframe [string] Available values: '1m', '5m', '15m',
    #        '30m', '1h', '3h', '6h', '12h', '1D', '7D', '14D', '1M'
    # @param section [string] Available values: "last", "hist"
    # @param params :limit [int32] Number of candles requested
    # @param params :start [int32] Filter start (ms)
    # @param params :end   [int32] Filter end (ms)
    # @param params :sort  [int32] if = 1 it sorts
    #        results returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.candles('tBTCUSD')
    def candles(symbol = 'tBTCUSD', timeframe = '1m', section = "hist", params = {})
      check_params(params, %i{limit start end sort})
      get("candles/trade:#{timeframe}:#{symbol}/#{section}", params).body
    end

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

    # Get active positions
    #
    # return [Array]
    #
    # @example:
    #    client.active_positions
    def active_positions
      authenticated_post("auth/r/positions").body
    end
  end
end
