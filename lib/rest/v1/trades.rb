# frozen_String_literal: true

module Bitfinex
  # RESTv1 API trade methods
  module RESTv1Trades
    # Get a list of the most recent trades for the given symbol.
    #
    # @param symbol [String] the name of the symbol
    # @param params [Hash]
    # @option params [time] :timestamp start of history to return
    # @option params [Numeric] :limit_trades
    # @return [Array]
    # @example:
    #   client.trades
    def trades(symbol = 'btcusd', params = {})
      check_params(params, %i[timestamp limit_trades])
      get("trades/#{symbol}", params).body
    end
  end
end
