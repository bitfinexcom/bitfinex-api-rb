module Bitfinexrb

  class Trade
    attr_accessor :tid, :timestamp, :price, :amount, :exchange, :type

    def initialize(values)
      self.tid = values['tid']
      self.timestamp = values['timestamp']
      self.price = values['price']
      self.amount = values['amount']
      self.exchange = values['exchange']
      self.type = values['type']
    end

  end

  class Trades < Base

    attr_accessor :all

    def initialize(symbol='btcusd', timestamp=nil, limit_trades=50)
      self.all = []
      resp = get(symbol, timestamp)
      if resp.success?
        if resp.is_a?(Array)
          resp.each do |trade|
            self.all << Trade.new(trade)
          end
        end
      end
    end

    def get(symbol, timestamp=nil)
      if timestamp
        self.class.get("/trades/#{symbol}&timestamp=#{timestamp}")
      else
        self.class.get("/trades/#{symbol}")
      end
    end
  end
end
