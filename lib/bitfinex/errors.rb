
require 'faraday'

module Bitfinex
  class ClientError < Exception; end
  class ParamsError < ClientError; end
  class InvalidAuthKeyError < ClientError; end
  class BlockMissingError < ParamsError; end
  class ServerError < Exception; end # Error reported back by Binfinex server
  class ConnectionClosed < Exception; end
  class BadRequestError < ServerError; end
  class NotFoundError < ServerError; end
  class ForbiddenError < ServerError; end
  class UnauthorizedError < ServerError; end
  class InternalServerError < ServerError; end
  class WebsocketError < ServerError; end

  class CustomErrors < Faraday::Response::Middleware
    def on_complete(env)
      msg = env.body.is_a?(Array) ? env.body : env.body('message')
      case env[:status]
      when 400
        raise BadRequestError, msg
      when 401
        raise UnauthorizedError, msg
      when 403
        raise ForbiddenError, msg
      when 404
        raise NotFoundError, msg
      when 500
        raise InternalServerError, msg
      else
        super
      end
    end
  end
end
