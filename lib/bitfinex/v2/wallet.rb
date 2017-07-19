module Bitfinex
  module V2::WalletClient

    # Get account wallets
    #
    # example:
    # client.wallets
    def wallets
      authenticated_post("auth/r/wallets").body
    end

  end
end
