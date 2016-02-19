module Bitfinex
  module WalletClient
    def balances(params = {})
      check_params(params, %i{type currency amount available})
      authenticated_post("balances", params).body
    end

    def margin_info
      authenticated_post("margin_info").body
    end

    def transfer(amount, currency, wallet_from, wallet_to)
      params = {
        amount: amount,
        currency: currency,
        wallet_from: wallet_from,
        wallet_to: wallet_to
      }
      authenticated_post("transfer", params).body
    end

    def withdraw(withdraw_type, walletselected, amount, params={})
      params.merge!({
        withdraw_type: withdraw_type,
        walletselected: walletselected,
        amount: amount})

      authenticated_post("withdraw", params).body
    end

    def key_info
      authenticated_post("key_info").body
    end
  end
end
