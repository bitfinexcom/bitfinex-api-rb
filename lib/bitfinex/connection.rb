require 'logger'
module Bitfinex
  # Network Layer for API Rest client
  module RestConnection
    private
    # Make an HTTP GET request
    def get(url, params={})
      rest_connection.get do |req|
        req.url build_url(url)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        params.each do |k,v|
          req.params[k] = v
        end
        req.options.timeout = config.rest_timeout
        req.options.open_timeout = config.rest_open_timeout
      end
    end

    # Make sure parameters are allowed for the HTTP call
    def check_params(params, allowed_params)
      if (params.keys - allowed_params).empty?
        return params
      else
        raise Bitfinex::ParamsError
      end
    end

    def rest_connection
      @conn ||= new_rest_connection
    end

    def build_url(url)
      URI.join(config.api_endpoint, url).path
    end

    def new_rest_connection
      Faraday.new(url: base_api_endpoint) do |conn|
        conn.use Bitfinex::CustomErrors
        conn.response :logger, Logger.new(STDOUT) , bodies: true  if config.debug_connection
        conn.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
        conn.adapter :net_http
      end
    end

    def base_api_endpoint
      url = URI.parse config.api_endpoint
      "#{url.scheme}://#{url.host}:#{url.port}"
    end

  end
end
