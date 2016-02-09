module Bitfinex

  class MarginInfo < Authenticated
    def all
      uri = "/#{@api_version}/margin_infos"
      resp = self.class.post(uri, headers: headers_for(uri))
      if resp.success?
        resp.parsed_response.first
      end
    end
  end
end
