module Bitfinex

  module AccountInfoClient 
    def account_info
      resp = authenticated_post("account_infos")
      resp.body
    end
  end

end
