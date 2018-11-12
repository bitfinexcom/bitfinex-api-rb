module Bitfinex
  module RESTv1Ticker
    # Gives innermost bid and asks and information on the most recent trade, as well as high, low and volume of the last 24 hours.
    #
    # @param symbol [string] The name of hthe symbol
    # @return [Hash]
    # @example:
    #   client.ticker
    def ticker(symbol = "btcusd")
      get("pubticker/#{symbol}").body
    end
  end
end
