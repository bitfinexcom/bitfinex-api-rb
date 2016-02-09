module Bitfinex
  module TickerClient
    def ticker(symbol='btcusd')
      resp = rest.get("/pubticker/#{symbol}")
      if resp.success?
        Ticker.new(JSON.parse(resp.body))
      end
    end
  end

  class Ticker < BaseResource
    set_properties :mid, :bid, :ask, :last_price, :low, :volume, :timestamp
  end

end
