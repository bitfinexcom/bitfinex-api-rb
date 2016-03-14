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


    # Call block passing all account related specific messages sent via websocket
    #
    # @param block [Block] The code to be executed when new message is received
    # @example:
    #   client.listen_account do |message|
    #     puts message.inspect
    #   end
    def listen_account(&block)
      raise BlockMissingError unless block_given?
      ws_auth(&block)
    end
  end

end
