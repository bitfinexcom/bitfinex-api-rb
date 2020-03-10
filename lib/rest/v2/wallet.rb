# frozen_string_literal: true

module Bitfinex
  # RESTv2 wallet methods
  module RESTv2Wallet
    # Get account wallets
    #
    # @example:
    #   client.wallets
    def wallets
      authenticated_post('auth/r/wallets').body
    end

    ###
    # Transfer between bitfinex wallets
    #
    # @param from [string] src to transfer funds from (exchange, margin ect...)
    # @param to [string] dest to transfer funds to (exchange, margin ect...)
    # @param currency_from [string] original currency of funds
    # @param currency_to [string] currency to convert funds to
    # @param amount [number] amount of funds to convert
    #
    # @return [Array] Raw notification
    ###
    def transfer(from, to, currency_from, currency_to, amount)
      payload = {
        from: from,
        to: to,
        currency: currency_from,
        currency_to: currency_to,
        amount: amount
      }

      authenticated_post('auth/w/transfer', params: payload).body
    end

    ###
    # Get the deposit address for the given currency
    #
    # @param wallet [string] dest wallet to transfer funds to
    # @param method [string] funds transfer protocol
    #
    # @return [Array] Raw notification
    ###
    def deposit_address(wallet, method)
      payload = { wallet: wallet, method: method, op_renew: 0 }
      authenticated_post('auth/w/deposit/address', params: payload).body
    end

    ###
    # Regenerate the deposit address for the given currency. All previous
    # addresses are still active and can receive funds.
    #
    # @param wallet [string] wallet to transfer funds from
    # @param method [string] funds transfer protocol
    #
    # @return [Array] Raw notification
    ###
    def create_deposit_address(wallet, method)
      payload = { wallet: wallet, method: method, op_renew: 1 }
      authenticated_post('auth/w/deposit/address', params: payload).body
    end

    ###
    # Withdraw from the given bitfinex wallet to the given cryptocurrency
    # address
    #
    # @param wallet [string] wallet to transfer funds from
    # @param method [string] funds transfer protocol
    # @param amount [number] amount of funds to withdraw
    # @param address [string] public key destination address
    #
    # @return [Array] Raw notification
    ###
    def withdraw(wallet, method, amount, address)
      payload = {
        wallet: wallet, method: method, amount: amount, address: address
      }

      authenticated_post('auth/w/withdraw', params: payload).body
    end
  end
end
