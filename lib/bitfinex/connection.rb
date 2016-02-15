module Bitfinex
  # Network Layer for API Rest client
  module RestConnection
    private 
    # Make an HTTP GET request
    def get(url, options={})
      rest_connection.get do |req|
        req.url build_url(url)
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.params = options[:params] if options.has_key?(:params) && !options[:params].empty?
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
        conn.use Faraday::Response::RaiseError
        conn.response :logger if config.debug 
        conn.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
        conn.adapter :net_http
      end
    end

    def base_api_endpoint
      url = URI.parse config.api_endpoint
      "#{url.scheme}://#{url.host}"
    end

  end
end
