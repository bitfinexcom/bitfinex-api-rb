module Bitfinex
  module AuthenticatedConnection

    private
    def authenticated_post(url, options = {})
      raise Bitfinex::InvalidAuthKeyError unless valid_key?
      complete_url = build_url(url)
      body = options[:params] || {}
      nonce = new_nonce

      payload = if config.api_version == 1
        build_payload("/v1/#{url}", options[:params], nonce)
      else
        "/api#{complete_url}#{nonce}#{body.to_json}"
      end

      response = rest_connection.post do |req|
        req.url complete_url
        req.body = body.to_json
        req.options.timeout = config.rest_timeout
        req.options.open_timeout = config.rest_open_timeout
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'

        if config.api_version == 1
          req.headers['X-BFX-PAYLOAD'] = payload
          req.headers['X-BFX-SIGNATURE'] = sign(payload)
          req.headers['X-BFX-APIKEY'] = config.api_key
        else
          req.headers['bfx-nonce'] = nonce
          req.headers['bfx-signature'] = sign(payload)
          req.headers['bfx-apikey'] = config.api_key
        end
      end
    end

    def build_payload(url, params = {}, nonce)
      payload = {}
      payload['nonce'] = nonce
      payload['request'] = url
      payload.merge!(params) if params
      Base64.strict_encode64(payload.to_json)
    end

    def new_nonce
      (Time.now.to_f * 10_000).to_i.to_s
    end

    def sign(payload)
      OpenSSL::HMAC.hexdigest('sha384', config.secret, payload)
    end

    def valid_key?
      !! (config.api_key && config.secret)
    end
  end
end
