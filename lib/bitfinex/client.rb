module Bitfinex
  class Client
    include Bitfinex::RestConnection
    include Bitfinex::TickerClient
    include Bitfinex::TradesClient
    include Bitfinex::FundingBookClient
    include Bitfinex::StatsClient
    include Bitfinex::Configurable
  end
end
