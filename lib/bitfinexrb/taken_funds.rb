
module Bitfinexrb

  class TakenFunds < Authenticated
    def all
      uri = "/#{@api_version}/taken_funds"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end

    def total
      uri = "/#{@api_version}/total_taken_funds"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end
  end
end
