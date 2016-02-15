module Bitfinex
  module StatsClient
    def stats(symbol = "btcusd")
        resp = get("stats/#{symbol}")
        resp.body.map do |stat|
          Stat.new(stat)
        end
    end
  end

  class Stat < BaseResource
    set_properties :period, :volume
  end
end
