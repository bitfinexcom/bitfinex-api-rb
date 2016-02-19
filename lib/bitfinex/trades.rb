module Bitfinex
  module TradesClient

    def trades symbol="btcusd", params={}
			check_params(params, %i{timestamp limit_trades})
      resp = get("trades/#{symbol}", params: params)
      resp.body
    end

  end
end
