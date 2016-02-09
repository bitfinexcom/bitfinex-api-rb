module Bitfinex
  # Network Layer for API Rest client
  module RestConnection

    # Make an HTTP GET request
    def get(url, options={})
      rest.get url, parse_params(options)
    end

    private 
    def rest
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
