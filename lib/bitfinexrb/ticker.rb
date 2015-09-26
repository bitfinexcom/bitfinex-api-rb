module Bitfinexrb
  class Ticker < Base
    attr_accessor :mid, :bid, :ask, :last_price, :low, :volume, :timestamp

    def initialize(symbol='btcusd')
      resp = get(symbol)
      if resp.success?
        self.mid = resp['mid']
        self.bid = resp['bid']
        self.ask = resp['ask']
        self.last_price = resp['last_price']
        self.low = resp['low']
        self.volume = resp['volume']
        self.timestamp = resp['timestamp']
      end
    end

    def get(symbol='btcusd')
      self.class.get("/pubticker/#{symbol}")
    end

  end
end
