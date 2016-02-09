module Bitfinex

  module TradeClient
    TRADE_PARAMS = %w{timestamp limit_trades}

    def trades symbol, params={}
      resp = rest.get("/trades/#{symbol}", check_params(params, TRADE_PARAMS))

      if resp.success?
        Trade.new(JSON.parse(resp.body))
      end
    end
  end

  class Trade
    values :tid, :timestamp, :price, :amount, :exchange, :type
  end

end
