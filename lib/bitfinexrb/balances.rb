
module Bitfinexrb

  class Balances < Authenticated
    def all
      uri = "/#{@api_version}/balances"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end
  end
end
