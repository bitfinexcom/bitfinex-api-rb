module Bitfinex
  class Client
    include Bitfinex::RestConnection
    include Bitfinex::AuthenticatedConnection
    include Bitfinex::TickerClient
    include Bitfinex::TradesClient
    include Bitfinex::FundingBookClient
    include Bitfinex::OrderbookClient
    include Bitfinex::StatsClient
    include Bitfinex::LendsClient
    include Bitfinex::SymbolsClient
    include Bitfinex::AccountInfoClient
    include Bitfinex::DepositClient
    include Bitfinex::Configurable
  end
end
