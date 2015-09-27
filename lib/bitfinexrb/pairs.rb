module Bitfinexrb
  #
  class Pairs < Base
    def all
      resp = self.class.get('/symbols')
      if resp.success?
        resp.map!
      end
    end
  end

  class << self
    def pairs
      @cached_pairs ||= Pairs.new.all
    end
  end
end
