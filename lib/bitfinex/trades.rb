module Bitfinex
  module TradesClient
    def trades symbol="btcusd", params={}
			check_params(params, %i{timestamp limit_trades})
      get("trades/#{symbol}", params: params).body
    end
  end
end
