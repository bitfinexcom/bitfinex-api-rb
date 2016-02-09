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
      Faraday.new(url: config.api_endpoint) do |builder|
        builder.use Bitfinex::CheckResponse
      end
    end

  end
end
