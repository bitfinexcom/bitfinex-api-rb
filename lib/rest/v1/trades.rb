module Bitfinex
  module RESTv1Trades
    # Get a list of the most recent trades for the given symbol.
    #
    # @param symbol [string] the name of the symbol
    # @param params :timestamp [time] Only show trades at or after this timestamp.
    # @param params :limit_trades [int] Limit the number of trades returned. Must be >= 1.
    # @return [Array]
    # @example:
    #   client.trades
    def trades(symbol="btcusd", params={})
      check_params(params, %i{timestamp limit_trades})
      get("trades/#{symbol}", params).body
    end
  end
end
