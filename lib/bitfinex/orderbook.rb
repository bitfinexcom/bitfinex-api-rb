module Bitfinex
  module OrderbookClient
    def orderbook(currency="btcusd", params = {})
      check_params(params, %i{limit_bids limit_asks group})
      get("book/#{currency}",params).body
    end
  end
end
