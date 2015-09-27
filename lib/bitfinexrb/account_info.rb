
module Bitfinexrb

  class AccountInfo < Authenticated
    def all
      uri = "/#{@api_version}/account_infos"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end
  end
end
