module Bitfinex
  module WalletClient
    def balances(params = {})
      check_params(params, %i{type currency amount available})
      authenticated_post("balances", params).body
    end
  end
end
