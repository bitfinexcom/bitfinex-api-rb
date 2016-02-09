module Bitfinex

  class Error
    def self.check_response(response)
      case response.status.to_i
      when 400 then BitFinex::BadRequest
      end
    end
  end

  # Check Faraday Response and raise the appropriate exception
  # in case of failure
  class CheckResponse < Faraday::Response::Middleware
    private
    def on_complete(response)
      if error = Bitfinex::Error.check_response(response)
        raise error
      end
    end
  end

  class ClientError < Error; end
  class BadRequest < ClientError; end
end
