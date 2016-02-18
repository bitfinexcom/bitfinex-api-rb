module Bitfinex
  module AuthenticatedConnection

    private
    def authenticated_post(url, options = {})
      complete_url = build_url(url)
      payload = build_payload("/v1/#{url}", options[:params])
      response = rest_connection.post do |req|
        req.url complete_url
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['X-BFX-PAYLOAD'] = payload
        req.headers['X-BFX-SIGNATURE'] = sign(payload)
        req.headers['X-BFX-APIKEY'] = config.api_key 
      end
    end

    def build_payload(url, params = {})
      payload = {}
      payload['nonce'] = (Time.now.to_f * 10_000).to_i.to_s
      payload['request'] = url
      payload.merge!(params) if params
      Base64.strict_encode64(payload.to_json)
    end

    def sign(payload)
      OpenSSL::HMAC.hexdigest('sha384', config.secret, payload)
    end

    def valid_key?
      !! (config.api_key && config.secret)
    end
  end
end
