module Bitfinex

  module OrderbookClient
    ORDERBOOK_ALLOWED_PARAMS = %i{limit_bids limit_asks group}

    def orderbook(currency="btcusd", params = {})
      resp = get("book/#{currency}", check_params(params, ORDERBOOK_ALLOWED_PARAMS))
      Orderbook.new(resp.body)
    end
  end

  class Orderbook < BaseResource
    set_properties :bids, :asks
  end
end
