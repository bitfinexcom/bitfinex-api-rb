module Bitfinex
  class Client
    include Bitfinex::RestConnection
    include Bitfinex::WebsocketConnection
    include Bitfinex::AuthenticatedConnection

    include Bitfinex::V1::TickerClient
    include Bitfinex::V1::TradesClient
    include Bitfinex::V1::FundingBookClient
    include Bitfinex::V1::OrderbookClient
    include Bitfinex::V1::StatsClient
    include Bitfinex::V1::LendsClient
    include Bitfinex::V1::SymbolsClient
    include Bitfinex::V1::AccountInfoClient
    include Bitfinex::V1::DepositClient
    include Bitfinex::V1::OrdersClient
    include Bitfinex::V1::PositionsClient
    include Bitfinex::V1::HistoricalDataClient
    include Bitfinex::V1::MarginFundingClient
    include Bitfinex::V1::WalletClient
    include Bitfinex::Configurable
  end
end
