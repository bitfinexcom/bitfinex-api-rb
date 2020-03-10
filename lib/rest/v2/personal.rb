# frozen_String_literal: true

module Bitfinex
  # RESTv2 personal data methods
  module RESTv2Personal
    # Get account historical daily performance
    #
    # @return [Hash]
    # @example:
    #   client.performance
    def performance
      authenticated_post('auth/r/stats/perf::1D/hist')
    end

    # Get the list of alerts
    #
    # @param type [String]
    # @return [Array]
    # @example:
    #   client.alerts
    def alerts(type = 'price')
      authenticated_post('auth/r/alerts', params: { type: type }).body
    end

    # Set a new alert
    #
    # @param price [Numeric]
    # @param symbol [String]
    # @param type [String]
    # @return [Hash]
    #
    # @example:
    #   client.alert(3000, "tBTCUSD")
    def alert(price, symbol = 'tBTCUSD', type = 'price')
      params = {
        type: type,
        price: price,
        symbol: symbol
      }
      authenticated_post('auth/w/alert/set', params: params).body
    end

    # Delete an existing alert
    #
    # @param price [Numeric]
    # @param symbol [String]
    # @return [Hash]
    #
    # @example:
    #   client.delete_alert(3000, "tBTCUSD")
    def delete_alert(price, symbol = 'tBTCUSD')
      authenticated_post("auth/w/alert/price:#{symbol}:#{price}/del").body
    end

    # Calculate available balance for order/offer
    #
    # @param rate [Numeric] Rate of the order/offer
    # @param dir [Numeric] direction of the order/offer
    #         (orders: > 0 buy, < 0 sell | offers:
    #             > 0 sell, < 0 buy)
    # @param type [String] Type of the order/offer
    #         EXCHANGE or MARGIN
    # @param symbol [String]
    # @return [Array]
    #
    # @example:
    #   client.available_balance(800, 1, 'EXCHANGE', 'tBTCUSD')
    def available_balance(rate, dir, type, symbol)
      params = {
        symbol: symbol,
        dir: dir,
        type: type,
        rate: rate
      }
      authenticated_post('auth/calc/order/avail', params: params).body
    end
  end
end
