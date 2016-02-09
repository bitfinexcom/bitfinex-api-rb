module Bitfinex

  class AccountInfo
    def all
      uri = "/#{@api_version}/account_infos"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end
  end
end
