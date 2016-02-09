module Bitfinex

  class Credits < Authenticated
    def all
      uri = "/#{@api_version}/credits"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end
  end
end
