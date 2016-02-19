module Bitfinex

  module OrdersClient

    def new_order(symbol, amount, type, side, price = nil, params = {}) 
			check_params(params, %i{exchange is_hidden is_postonly ocoorder buy_price_oco})

      params.merge({
        symbol: symbol, 
        amount: amount,
        type: type,
        side: side,
        price: price})

      resp = authenticated_post("order/new", params: params)
			resp.body
    end

    def multiple_orders(orders)
      resp = authenticated_post("order/new/multi", params: orders)
			resp.body
    end

		
  end
end
