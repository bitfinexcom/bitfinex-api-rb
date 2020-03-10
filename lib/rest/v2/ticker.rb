# frozen_string_literal: true

module Bitfinex
  # RESTv2 ticker methods
  module RESTv2Ticker
    # Gives innermost bid and asks and information on
    # the most recent trade, as well as high, low and
    # volume of the last 24 hours.
    #
    # @param symbols a list of symbols
    # @return [Hash]
    # @example:
    #   client.ticker("tBTCUSD","tLTCUSD","fUSD")
    def ticker(*symbols)
      if symbols.size == 1
        get("ticker/#{symbols.first}").body
      else
        get('tickers', symbols: symbols.flatten.join(',').to_s).body
      end
    end
  end
end
