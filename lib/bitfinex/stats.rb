module Bitfinex
  module StatsClient
    def stats(symbol = "btcusd")
      resp = get("stats/#{symbol}")
      resp.body
    end
  end
end
