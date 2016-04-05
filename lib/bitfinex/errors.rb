require 'faraday'

module Bitfinex
  class ClientError < Exception; end
  class ParamsError < ClientError; end
  class InvalidAuthKeyError < ClientError; end
  class BlockMissingError < ParamsError; end
  class ServerError < Exception; end # Error reported back by Binfinex server
  class BadRequestError < ServerError; end
  class NotFoundError < ServerError; end
  class ForbiddenError < ServerError; end
  class UnauthorizedError < ServerError; end
  class InternalServerError < ServerError; end

  class CustomErrors < Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 400
        raise BadRequestError, env.body['message']
      when 401
        raise UnauthorizedError
      when 403
        raise ForbiddenError
      when 404
        raise NotFoundError
      when 500
        raise InternalServerError
      else
        super
      end
    end
  end
end
