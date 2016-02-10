module Bitfinex
  class Client
    include Bitfinex::RestConnection
    include Bitfinex::TickerClient
    include Bitfinex::TradesClient
    include Bitfinex::Configurable

    def check_params(params, allowed_params)
      unless (params.keys - allowed_params).empty?
        raise Bitfinex::ParamsError
      end
    end
  end
end
