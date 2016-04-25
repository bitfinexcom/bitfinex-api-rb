module Bitfinex

  module OrdersClient

    # Submit a new order
    # @param symbol [string] The name of the symbol (see `#symbols`)
    # @param amount [decimal] Order size: how much to buy or sell
    # @param type [string] Either “market” / “limit” / “stop” / “trailing-stop” / “fill-or-kill” / “exchange market” / “exchange limit” / “exchange stop” / “exchange trailing-stop” / “exchange fill-or-kill”. (type starting by “exchange ” are exchange orders, others are margin trading orders)
    # @param side [string] Either “buy” or “sell”
    # @param price [decimal] Price to buy or sell at. Must be positive. Use random number for market orders.
    # @param params :is_hidden [bool] (optional) true if the order should be hidden. Default is false
    # @param params :is_postonly [bool] (optional) true if the order should be post only. Default is false. Only relevant for limit orders
    # @param params :ocoorder [bool] Set an additional STOP OCO order that will be linked with the current order
    # @param params :buy_price_oco [decimal] If ocoorder is true, this field represent the price of the OCO stop order to place
    # @return [Hash]
    # @example:
    #   client.new_order("usdbtc", 100, "market", "sell", 0)
    def new_order(symbol, amount, type, side, price = nil, params = {})
      check_params(params, %i{is_hidden is_postonly ocoorder buy_price_oco})

      # for 'market' order, we need to pass a random positive price, not nil
      price ||= 0.001 if type == "market" || type == "exchange market"

      params.merge!({
        symbol: symbol,
        amount: amount.to_s,
        type: type,
        side: side,
        exchange: 'bitfinex',
        price: price.to_s
      })
      authenticated_post("order/new", params: params).body
    end

    # Submit several new orders at once
    #
    # @param orders [Array] Array of Hash with the following elements
    # @param orders :symbol [string] The name of the symbol
    # @param orders :amount [decimal] Order size: how much to buy or sell
    # @param orders :price [decimal] Price to buy or sell at. May omit if a market order
    # @param orders :exchange [string] "bitfinex"
    # @param orders :side [string] Either “buy” or “sell”
    # @param orders :type [string] Either “market” / “limit” / “stop” / “trailing-stop” / “fill-or-kill”
    # @return [Hash] with a `object_id` that is an `Array`
    # @example:
    #   client.multiple_orders([{symbol: "usdbtc", amount: 10, price: 0, exchange: "bitfinex", side: "buy", type: "market"}])
    def multiple_orders(orders)
      authenticated_post("order/new/multi", params: orders).body
    end

    # Cancel an order
    #
    # @param ids [Array] or [integer] or nil
    #   if it's Array it's supposed to specify a list of IDS
    #   if it's an integer it's supposed to be a single ID
    #   if it's not specified it deletes all the orders placed
    # @return [Hash]
    # @example
    #   client.cancel_orders([100,231,400])
    def cancel_orders(ids=nil)
      case ids
      when Array
          authenticated_post("order/cancel/multi", params: {order_ids: ids.map(&:to_i)}).body
      when Numeric, String
          authenticated_post("order/cancel", params: {order_id: ids.to_i}).body
      when NilClass
          authenticated_post("order/cancel/all").body
      else
          raise ParamsError
      end
    end

    # Replace an orders with a new one
    #
    # @param id [int] the ID of the order to replace
    # @param symbol [string] the name of the symbol
    # @param amount [decimal] Order size: how much to buy or sell
    # @param type [string] Either “market” / “limit” / “stop” / “trailing-stop” / “fill-or-kill” / “exchange market” / “exchange limit” / “exchange stop” / “exchange trailing-stop” / “exchange fill-or-kill”. (type starting by “exchange ” are exchange orders, others are margin trading orders)
    # @param side [string] Either “buy” or “sell”
    # @param price [decimal] Price to buy or sell at. May omit if a market order
    # @param is_hidden [bool] (optional) true if the order should be hidden. Default is false
    # @param use_remaining [bool] (optional) will use the amount remaining of the canceled order as the amount of the new order. Default is false
    # @return [Hash] the order
    # @example:
    #   client.replace_order(100,"usdbtc", 10, "market", "buy", 0)
    def replace_order(id, symbol, amount, type, side, price, is_hidden=false, use_remaining=false)
      params = {
        order_id: id.to_i,
        symbol: symbol,
        amount: amount.to_s,
        type: type,
        side: side,
        exchange: 'bitfinex',
        is_hidden: is_hidden,
        use_remaining: use_remaining,
        price: price.to_s
      }
      authenticated_post("order/cancel/replace", params: params).body
    end

    # Get the status of an order. Is it active? Was it cancelled? To what extent has it been executed? etc.
    #
    # @param id
    # @return [Hash]
    # @exmaple:
    #   client.order_status(100)
    def order_status(id)
      authenticated_post("order/status", params: {order_id: id.to_i}).body
    end


    # View your active orders.
    #
    # @return [Hash]
    # @example:
    #   client.orders
    def orders
      authenticated_post("orders").body
    end

  end
end
