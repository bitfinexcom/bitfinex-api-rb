module Bitfinex
  class Orderbook < Base

    attr_accessor :bids, :asks

    def initialize(symbol='btcusd')
      resp = get(symbol)
      if resp.success?
        self.bids = resp['bids']
        self.asks = resp['asks']
      end
    end

    def get(symbol='btcusd')
      self.class.get("/book/#{symbol}?group=1&limit_bids=20&limit_asks=20")
    end
  end
end
