# frozen_String_literal: true

module Bitfinex
  # RESTv2 stats methods
  module RESTv2Stats
    # Various statistics about the requested pair.
    #
    # @param symbol [String] The symbol you want information about.
    # @param key [String] Allowed values: "funding.size",
    #     "credits.size", "credits.size.sym", "pos.size"
    # @param side [String] Available values: "long", "short"
    # @param section [String] Available values: "last", "hist"
    # @param size [String] Available values: '1m'
    # @param params [Hash]
    # @option params [Numeric] :sort if = 1 it sorts results
    #     returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.stats('fUSD', 'pos.size')
    def stats(symbol = 'fUSD', key = 'funding.size', side = 'long', section = 'last', size = '1m', params = {}) #rubocop:disable all
      check_params(params, %i[sort])
      get("stats1/#{key}:#{size}:#{symbol}:#{side}/#{section}").body
    end
  end
end
