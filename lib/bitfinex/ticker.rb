module Bitfinex

  module TickerClient

    def ticker(symbol = "btcusd")
      resp = get("pubticker/#{symbol}")
      Ticker.new(resp.body)
    end

  end

  class Ticker < BaseResource
    set_properties :mid, :bid, :ask, :last_price, :low, :volume, :timestamp
  end

end
