module Bitfinex
  class Client
    include Bitfinex::RestConnection
    include Bitfinex::TickerClient
    include Bitfinex::TradesClient
    include Bitfinex::Configurable
  end
end
