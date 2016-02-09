module Bitfinex

  class Lendbook < Base

    attr_accessor :bids, :rate, :amount, :period, :timestamp, :frr, :asks, :limit_bids, :limit_asks

    def initialize(currency='USD', limit_bids=50, limit_asks=50)
      self.limit_bids = limit_bids
      self.limit_asks = limit_asks
      resp = get(currency)
      if resp.success?
        self.bids = resp['bids']
        self.rate = resp['rate']
        self.amount = resp['amount']
        self.period = resp['period']
        self.timestamp = resp['timestamp']
        self.frr = resp['frr']
        self.asks = resp['asks']
      end
    end


    def get(currency)
      self.class.get("/lendbook/#{currency}?limit_bids=#{self.limit_bids}&limit_asks=#{self.limit_asks}")
    end
  end
end
