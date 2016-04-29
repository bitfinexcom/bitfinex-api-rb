module Bitfinex
  module WalletClient

    # See your balances.
    #
    # @param params :type [string] “trading”, “deposit” or “exchange”.
    # @param params :currency [string] currency
    # @param params :amount [decimal] How much balance of this currency in this wallet
    # @param params :available [decimal] How much X there is in this wallet that is available to trade
    # @return [Array]
    # @example:
    #   client.balances
    def balances(params = {})
      check_params(params, %i{type currency amount available})
      authenticated_post("balances", params: params).body
    end

    # See your trading wallet information for margin trading.
    #
    # @return [Array]
    # @example:
    #   client.margin_infos
    def margin_infos
      authenticated_post("margin_infos").body
    end

    # See a symmary of your trade volume, funding profits etc.
    #
    # @return [Hash]
    # @example:
    #    client.summary
    def summary
      authenticated_post("summary").body
    end

    # Allow you to move available balances between your wallets.
    #
    # @param amount [decimal] Amount to transfer
    # @param currency [string] Currency of funds to transfer
    # @param wallet_from [string] Wallet to transfer from
    # @param wallet_to [string] Wallet to transfer to
    # @return [Array]
    # @example:
    #   client.transfer(10, 'btc', "exchange", "deposit")
    def transfer(amount, currency, wallet_from, wallet_to)
      params = {
        amount: amount.to_s,
        currency: currency.upcase,
        walletfrom: wallet_from.downcase,
        walletto: wallet_to.downcase
      }
      authenticated_post("transfer", params: params).body
    end

    # Allow you to request a withdrawal from one of your wallet.
    #
    # @param withdraw_type [string] can be “bitcoin”, “litecoin” or “darkcoin” or “tether” or “wire”
    # @param walletselected [string] The wallet to withdraw from, can be “trading”, “exchange”, or “deposit”.
    # @param amount [decimal] Amount to withdraw
    # For Cryptocurrencies (including tether):
    # @param params :address [string] Destination address for withdrawal
    # For wire withdrawals
    # @param params :account_name [string] account name
    # @param params :account_number [string] account number
    # @param params :bank_name [string] bank name
    # @param params :bank_address [string] bank address
    # @param params :bank_city [string] bank city
    # @param params :bank_country [string] bank country
    # @param params :detail_payment [string] (optional) message to beneficiary
    # @param params :intermediary_bank_name [string] (optional) intermediary bank name
    # @param params :intermediary_bank_address [string] (optional) intermediary bank address
    # @param params :intermediary_bank_city [string] (optional) intermediary bank city
    # @param params :intermediary_bank_country [string] (optional) intermediary bank country
    # @param params :intermediary_bank_account [string] (optional) intermediary bank account
    # @param params :intermediary_bank_swift [string] (optional) intemediary bank swift
    # @param params :expressWire [int] (optional). “1” to submit an express wire withdrawal, “0” or omit for a normal withdrawal
    # @return [Array]
    # @example:
    #   client.withdraw("bitcoin","deposit",1000, address: "1DKwqRhDmVyHJDL4FUYpDmQMYA3Rsxtvur")
    def withdraw(withdraw_type, walletselected, amount, params={})
      params.merge!({
        withdraw_type: withdraw_type,
        walletselected: walletselected.downcase,
        amount: amount.to_s})

      authenticated_post("withdraw", params: params).body
    end

    # Check the permissions of the key being used to generate this request
    #
    # @return [Hash]
    # @example:
    #   client.key_info
    def key_info
      authenticated_post("key_info").body
    end
  end
end
