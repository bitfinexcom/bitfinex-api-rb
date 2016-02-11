module Bitfinex

  module TradesClient
    TRADES_ALLOWED_PARAMS = %i{timestamp limit_trades}

    def trades symbol, params={}
      resp = get("/trades/#{symbol}", params: check_params(params, TRADES_ALLOWED_PARAMS))
      resp.body.map do |trade_hash|
       Trade.new(trade_hash)
      end
    end
  end

  class Trade < BaseResource
    set_properties :tid, :timestamp, :price, :amount, :exchange, :type
  end

end
