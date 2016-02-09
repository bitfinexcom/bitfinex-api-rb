module Bitfinex

  class Lend
    attr_accessor :rate, :amount, :timestamp

    def initialize(values)
      self.rate = values['rate']
      self.amount = values['amount_lent']
      self.timestamp = values['timestamp']
    end
  end

  class Lends < Base
    attr_accessor :lends

    def initialize(currency='USD', timestamp=nil, limit_lends=50)
      self.lends = []
      resp = get(currency)
      if resp.success?
        resp.each do |lend|
          self.lends << Lend.new(lend)
        end
      end
    end

    def get(currency)
      self.class.get("/lends/#{currency}")
    end
  end
end
