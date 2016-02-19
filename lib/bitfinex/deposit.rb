module Bitfinex
  module DepositClient
    def deposit method, wallet_name, renew=0
      params = {
        method: method, 
        wallet_name: wallet_name, 
        renew: renew
      }

      authenticated_post("deposit/new", params).body
    end
  end
end
