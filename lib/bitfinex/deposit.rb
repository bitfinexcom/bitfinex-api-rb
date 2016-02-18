module Bitfinex
  module DepositClient

    def deposit method, wallet_name, renew=0
      data = {
        method: method, 
        wallet_name: wallet_name, 
        renew: renew
      }

      resp = authenticated_post("deposit/new", data) 
      Deposit.new(resp.body)
    end
  end

  class Deposit < BaseResource
    set_properties :result, :method, :currency, :address
  end
end
