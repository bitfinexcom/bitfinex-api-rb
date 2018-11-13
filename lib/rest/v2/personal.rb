module Bitfinex
  module RESTv2Personal

    # Get account wallets
    #
    # @example:
    #   client.wallets
    def wallets
      authenticated_post("auth/r/wallets").body
    end

    # Get account historical daily performance
    #
    # @example:
    #   client.performance
    def performance
      authenticated_post("auth/r/stats/perf::1D/hist")
    end

    # Get the list of alerts
    #
    # @example:
    #   client.alerts
    def alerts(type = 'price')
      authenticated_post("auth/r/alerts", params: {type: type}).body
    end

    # Set a new alert
    #
    # @param price
    # @param symbol
    # @param type
    #
    # @example:
    #   client.alert(3000, "tBTCUSD")
    def alert(price, symbol = "tBTCUSD", type = "price")
      params = {
        type: type,
        price: price,
        symbol: symbol
      }
      authenticated_post("auth/w/alert/set", params: params).body
    end

    # Delete an existing alert
    #
    # @param price
    # @param symbol
    #
    # @example:
    #   client.delete_alert(3000, "tBTCUSD")
    def delete_alert(price, symbol = "tBTCUSD")
      authenticated_post("auth/w/alert/price:#{symbol}:#{price}/del").body
    end

    # Calculate available balance for order/offer
    #
    # @param rate [int] Rate of the order/offer
    # @param dir [int] direction of the order/offer
    #         (orders: > 0 buy, < 0 sell | offers:
    #             > 0 sell, < 0 buy)
    # @param type [string] Type of the order/offer
    #         EXCHANGE or MARGIN
    # @param symbol [string]

    # @example:
    #   client.available_balance(800, 1, 'EXCHANGE', 'tBTCUSD')
    def available_balance(rate, dir, type, symbol)
      params = {
        symbol: symbol,
        dir: dir,
        type: type,
        rate: rate
      }
      authenticated_post("auth/calc/order/avail", params: params).body
    end
  end
end
