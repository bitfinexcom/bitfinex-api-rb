module Bitfinex
  module RESTv1Deposit
    # Return your deposit address to make a new deposit.
    #
    # @param method [string] Method of deposit (methods accepted: “bitcoin”, “litecoin”, “darkcoin”, “mastercoin” (tethers)).
    # @param wallet_name [string] Wallet to deposit in (accepted: “trading”, “exchange”, “deposit”). Your wallet needs to already exist
    # @params renew [integer] (optional) Default is 0. If set to 1, will return a new unused deposit address
    #
    # @return [Hash] confirmation of your deposit
    # @example:
    #   client.deposit("bitcoin", "exchange")
    def deposit (method, wallet_name, renew=0)
      params = {
        method: method,
        wallet_name: wallet_name,
        renew: renew
      }

      authenticated_post("deposit/new", params: params).body
    end
  end
end
