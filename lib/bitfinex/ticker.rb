module Bitfinex

  module TickerClient
    def ticker(symbol = "btcusd")
      resp = get("pubticker/#{symbol}")
      resp.body
    end
  end

end
