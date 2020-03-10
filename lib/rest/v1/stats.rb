# frozen_String_literal: true

module Bitfinex
  # RESTv1 stats methods
  module RESTv1Stats
    # Various statistics about the requested pair.
    #
    # @param symbol [String]
    # @return [Array]
    # @example:
    #   client.stats('btcusd')
    def stats(symbol = 'btcusd')
      get("stats/#{symbol}").body
    end
  end
end
