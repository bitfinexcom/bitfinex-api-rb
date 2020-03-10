# frozen_string_literal: true

module Bitfinex
  # RESTv1 API wallet methods
  module RESTv1Wallet
    # See your balances.
    #
    # @param params [Hash]
    # @option params [string] :type "trading", "deposit" or "exchange".
    # @option params [string] :currency
    # @option params [decimal] :amount
    # @option params [decimal] :available
    # @return [Array]
    # @example:
    #   client.balances
    def balances(params = {})
      check_params(params, %i[type currency amount available])
      authenticated_post('balances', params: params).body
    end

    # See your trading wallet information for margin trading.
    #
    # @return [Array]
    # @example:
    #   client.margin_infos
    def margin_infos
      authenticated_post('margin_infos').body
    end

    # See a symmary of your trade volume, funding profits etc.
    #
    # @return [Hash]
    # @example:
    #    client.summary
    def summary
      authenticated_post('summary').body
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
      authenticated_post('transfer', params: params).body
    end

    # Allow you to request a withdrawal from one of your wallet.
    #
    # @param withdraw_type [String]
    # @param walletselected [String] the wallet to withdraw from
    # @param amount [Number] amount to withdraw
    # @param params [Hash]
    # @option params [String] :address Destination address for withdrawal
    # @option params [String] :account_name account name
    # @option params [String] :account_number account number
    # @option params [String] :bank_name
    # @option params [String] :bank_address
    # @option params [String] :bank_city
    # @option params [String] :bank_country
    # @option params [String] :detail_payment message to beneficiary
    # @option params [String] :intermediary_bank_name
    # @option params [String] :intermediary_bank_address
    # @option params [String] :intermediary_bank_city
    # @option params [String] :intermediary_bank_country
    # @option params [String] :intermediary_bank_account
    # @option params [String] :intermediary_bank_swift
    # @option params [Number] :expressWire "1" to for express wire withdrawals
    # @return [Array]
    # @example:
    #   client.withdraw(
    #     "bitcoin", "deposit", 1000,
    #     address: "1DKwqRhDmVyHJDL4FUYpDmQMYA3Rsxtvur"
    #   )
    def withdraw(withdraw_type, walletselected, amount, params = {})
      params.merge!({
                      withdraw_type: withdraw_type,
                      walletselected: walletselected.downcase,
                      amount: amount.to_s
                    })

      authenticated_post('withdraw', params: params).body
    end

    # Check the permissions of the key being used to generate this request
    #
    # @return [Hash]
    # @example:
    #   client.key_info
    def key_info
      authenticated_post('key_info').body
    end
  end
end
