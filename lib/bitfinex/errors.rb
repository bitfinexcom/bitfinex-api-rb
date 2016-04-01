require 'faraday'

module Bitfinex
  class ClientError < Exception; end
  class ParamsError < ClientError; end
  class InvalidAuthKeyError < ClientError; end
  class BlockMissingError < ParamsError; end
  class ServerError < Exception; end # Error reported back by Binfinex server

  class CustomErrors < Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 400..500
        raise ServerError, env.body['message']
      else
        super
      end
    end
  end
end
