module Bitfinex
  module V2::OrdersClient

    # Get active orders
    #
    # example:
    # client.orders
    def orders
      authenticated_post("auth/r/orders").body
    end

  end
end
