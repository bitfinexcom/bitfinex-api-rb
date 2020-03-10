# frozen_string_literal: true

module Bitfinex
  # RESTv1 API deposit methods
  module RESTv1Deposit
    # Return your deposit address to make a new deposit.
    #
    # @param method [string]
    # @param wallet_name [string]
    # @param renew [integer] if 1, will return new deposit address
    #
    # @return [Hash] confirmation of your deposit
    # @example:
    #   client.deposit("bitcoin", "exchange")
    def deposit(method, wallet_name, renew = 0)
      params = {
        method: method,
        wallet_name: wallet_name,
        renew: renew
      }

      authenticated_post('deposit/new', params: params).body
    end
  end
end
