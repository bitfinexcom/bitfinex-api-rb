# frozen_string_literal: true

module Bitfinex
  # RESTv1 API order manipulation methods
  module RESTv1Orders
    ###
    # Submit a new order
    # @param symbol [string] The name of the symbol (see `#symbols`)
    # @param amount [decimal] Order size: how much to buy or sell
    # @param type [string] order type
    # @param side [string] 'buy' or 'sell'
    # @param price [Number]
    # @param params [Hash]
    # @option params [Boolean?] :is_hidden
    # @option params [Boolean?] :is_postonly
    # @option params [Boolean?] :ocoorder
    # @option params [Number?] :buy_price_oco
    # @option params [Number?] :sell_price_oco
    # @return [Hash]
    # @example:
    #   client.new_order("usdbtc", 100, "market", "sell", 0)
    ###
    def new_order(symbol, amount, type, side, price = nil, params = {}) # rubocop:disable all
      check_params(params, %i[
                     is_hidden is_postonly ocoorder buy_price_oco
                     use_all_available sell_price_oco
                   ])

      # for 'market' order, we need to pass a random positive price, not nil
      price = 0.001 if ['market', 'exchange market'].include?(type)
      params.merge!({
                      symbol: symbol, amount: amount.to_s, type: type,
                      side: side, exchange: 'bitfinex',
                      price: format('%<price>.10f', price: price.to_f.round(10))
                    })

      authenticated_post('order/new', params: params).body
    end

    # Submit several new orders at once
    #
    # @param orders [Array] Array of Hash with the following elements
    # @option orders [string] :symbol
    # @option orders [decimal] :amount
    # @option orders [decimal] :price
    # @option orders [string] :exchange "bitfinex"
    # @option orders [string] :side either "buy" or "sell"
    # @option orders [string] :type
    # @return [Hash]
    # @example:
    #   client.multiple_orders([{
    #                             symbol: "usdbtc", amount: 10, price: 0,
    #                             exchange: "bitfinex", side: "buy",
    #                             type: "market"
    #                           }])
    def multiple_orders(orders)
      authenticated_post('order/new/multi', params: { orders: orders }).body
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
    def cancel_orders(ids = nil) # rubocop:disable Metrics/MethodLength
      case ids
      when Array
        authenticated_post('order/cancel/multi', params: {
                             order_ids: ids.map(&:to_i)
                           }).body
      when Numeric, String
        authenticated_post('order/cancel', params: { order_id: ids.to_i }).body
      when NilClass
        authenticated_post('order/cancel/all').body
      else
        raise ParamsError
      end
    end

    # Replace an orders with a new one
    #
    # @param id [int] the ID of the order to replace
    # @param symbol [string]
    # @param amount [decimal]
    # @param type [string]
    # @param side [string]
    # @param price [decimal]
    # @param is_hidden [bool?]
    # @param use_remaining [bool]
    # @return [Hash] the order
    # @example:
    #   client.replace_order(100,"usdbtc", 10, "market", "buy", 0)
    def replace_order( # rubocop:disable all
      id, symbol, amount, type, side, price, is_hidden = false,
      use_remaining = false
    )
      authenticated_post('order/cancel/replace', params: {
                           order_id: id.to_i,
                           symbol: symbol,
                           amount: amount.to_s,
                           type: type,
                           side: side,
                           exchange: 'bitfinex',
                           is_hidden: is_hidden,
                           use_remaining: use_remaining,
                           price: price.to_s
                         }).body
    end

    # Get the status of an order. Is it active? Was it cancelled?
    # To what extent has it been executed? etc.
    #
    # @param id
    # @return [Hash]
    # @exmaple:
    #   client.order_status(100)
    def order_status(id)
      authenticated_post('order/status', params: { order_id: id.to_i }).body
    end

    # View your active orders.
    #
    # @return [Hash]
    # @example:
    #   client.orders
    def orders
      authenticated_post('orders').body
    end
  end
end
