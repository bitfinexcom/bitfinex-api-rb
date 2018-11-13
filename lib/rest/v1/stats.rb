module Bitfinex
  module RESTv1Stats
    # Various statistics about the requested pair.
    #
    # @param symbol [string] Symbol of the pair you want info about. Default 'btcusd'
    # @return [Array]
    # @example:
    #   client.stats('btcusd')
    def stats(symbol = "btcusd")
      get("stats/#{symbol}").body
    end
  end
end
