module Bitfinex
  module V2::WalletClient

    def wallets
      authenticated_post("auth/r/wallets").body
    end

  end
end
