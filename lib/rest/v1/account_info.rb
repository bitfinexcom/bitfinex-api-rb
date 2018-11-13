module Bitfinex
  module RESTv1AccountInfo
    # Get account information
    #
    # @return [Hash] your account information
    # @example:
    #   client.account_info
    def account_info
      resp = authenticated_post("account_infos")
      resp.body
    end

    # See the fees applied to your withdrawals
    #
    # @return [Hash]
    # @example:
    #   client.fees
    def fees
      resp = authenticated_post("account_fees")
      resp.body
    end
  end
end
