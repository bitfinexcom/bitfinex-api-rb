# frozen_string_literal: true

require 'faraday'

module Bitfinex
  class ClientError < RuntimeError; end
  class ParamsError < ClientError; end
  class InvalidAuthKeyError < ClientError; end
  class BlockMissingError < ParamsError; end
  class ServerError < RuntimeError; end
  class ConnectionClosed < RuntimeError; end
  class BadRequestError < ServerError; end
  class NotFoundError < ServerError; end
  class ForbiddenError < ServerError; end
  class UnauthorizedError < ServerError; end
  class InternalServerError < ServerError; end
  class WebsocketError < ServerError; end

  # Custom error class, used internally
  class CustomErrors < Faraday::Response::Middleware
    # @param env [Hash]
    # @return [nil]
    def on_complete(env) # rubocop:disable Metrics/MethodLength
      case env[:status]
      when 400
        raise BadRequestError, env.body['message']
      when 401
        raise UnauthorizedError, env.body['message']
      when 403
        raise ForbiddenError, env.body['message']
      when 404
        raise NotFoundError, env.url
      when 500
        raise InternalServerError, env.body
      else
        super
      end
    end
  end
end
