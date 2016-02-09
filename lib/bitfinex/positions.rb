module Bitfinex

  class Positions < Authenticated

    def all
      uri = "/#{@api_version}/positions"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end

  end
end
