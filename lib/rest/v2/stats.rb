module Bitfinex
  module RESTv2Stats

    # Various statistics about the requested pair.
    #
    # @param symbol [string] The symbol you want information about.
    # @param key [string] Allowed values: "funding.size",
    #     "credits.size", "credits.size.sym", "pos.size"
    # @param side [string] Available values: "long", "short"
    # @param section [string] Available values: "last", "hist"
    # @param size [string] Available values: '1m'
    # @param params :sort [int32] if = 1 it sorts results
    #     returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.stats('fUSD', 'pos.size')
    def stats(symbol = 'fUSD', key = 'funding.size', side = "long", section = "last", size = '1m', params = {})
      check_params(params, %i{sort})
      get("stats1/#{key}:#{size}:#{symbol}:#{side}/#{section}").body
    end
  end
end
