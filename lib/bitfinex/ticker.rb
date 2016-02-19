module Bitfinex
  module TickerClient
    def ticker(symbol = "btcusd")
      get("pubticker/#{symbol}").body
    end
  end
end
