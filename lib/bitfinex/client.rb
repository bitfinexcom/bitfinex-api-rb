module Bitfinex
  class Client
    include Bitfinex::RestConnection
    include Bitfinex::WebsocketConnection
    include Bitfinex::AuthenticatedConnection
    include Bitfinex::Configurable


    def initialize
      if config.api_version == 1
        extend Bitfinex::V1::TickerClient
        extend Bitfinex::V1::TradesClient
        extend Bitfinex::V1::FundingBookClient
        extend Bitfinex::V1::OrderbookClient
        extend Bitfinex::V1::StatsClient
        extend Bitfinex::V1::LendsClient
        extend Bitfinex::V1::SymbolsClient
        extend Bitfinex::V1::AccountInfoClient
        extend Bitfinex::V1::DepositClient
        extend Bitfinex::V1::OrdersClient
        extend Bitfinex::V1::PositionsClient
        extend Bitfinex::V1::HistoricalDataClient
        extend Bitfinex::V1::MarginFundingClient
        extend Bitfinex::V1::WalletClient
      else
        extend Bitfinex::V2::TickerClient
        extend Bitfinex::V2::StatsClient
        extend Bitfinex::V2::UtilsClient
        extend Bitfinex::V2::PersonalClient
        extend Bitfinex::V2::TradingClient
        extend Bitfinex::V2::MarginClient
      end

      @mutex = Mutex.new
      @c_counter = 1
    end
  end
end
