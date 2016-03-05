module Bitfinex

  module AccountInfoClient 
    
    # Get account information
    #
    # @return [Hash] your account information
    # @example:
    #   client.account_info
    def account_info
      resp = authenticated_post("account_infos")
      resp.body
    end
  end

end
