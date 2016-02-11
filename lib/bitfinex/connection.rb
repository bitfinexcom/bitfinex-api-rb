module Bitfinex
  # Network Layer for API Rest client
  module RestConnection

    # Make an HTTP GET request
    def get(url, options={})
      rest_connection.get do |req|
        req.url url
        req.params = options[:params] if options.has_key?(:params) && !options[:params].empty?
      end
    end

    def check_params(params, allowed_params)
      if (params.keys - allowed_params).empty?
        return params
      else
        raise Bitfinex::ParamsError
      end
    end

    private 
    def rest_connection
      @conn ||= new_rest_connection
    end

    def new_rest_connection
      Faraday.new(url: config.api_endpoint) do |conn|
        conn.use Faraday::Response::RaiseError
        conn.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
        conn.adapter :net_http
      end
    end

  end
end
