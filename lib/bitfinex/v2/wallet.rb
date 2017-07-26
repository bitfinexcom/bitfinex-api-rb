module Bitfinex
  module V2::WalletClient

    # Get account wallets
    #
    # example:
    #   client.wallets
    def wallets
      authenticated_post("auth/r/wallets").body
    end

    # Listen to authenticated channel
    #
    # Documentation:
    #    https://docs.bitfinex.com/v2/reference#account-info
    #
    # example:
    #   client.listen_account do |account|
    #     puts account
    #   end
    def listen_account(&block)
      raise BlockMissingError unless block_given?
      ws_auth(&block)
    end


  end
end
