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

      authenticated_post("order/new", params: params).body
    end

    def multiple_orders(orders)
      authenticated_post("order/new/multi", params: orders).body
    end

		def cancel_orders(ids=nil)
      payload = ids.kind_of?(Array) ? {order_ids: ids} : {order_id: ids}
		  authenticated_post("order/cancel/multi", payload).body
		end

    def cancel_all_orders
      authenticated_post("order/cancel/all").body
    end
		
    def replace_order(id, symbol, amount, type, side, price, params = {})
			check_params(params, %i{exchange is_hidden})
      params.merge({
        order_id: id,
        symbol: symbol, 
        amount: amount,
        type: type,
        side: side,
        price: price})

      authenticated_post("order/cancel/replace", params).body
    end

    def order_status(id)
      authenticated_post("order/status", order_id: id).body
    end

    def orders
      authenticated_post("orders").body
    end
		
  end
end
