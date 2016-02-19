module Bitfinex
  module StatsClient
    def stats(symbol = "btcusd")
      get("stats/#{symbol}").body
    end
  end
end
