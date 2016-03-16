module Bitfinex
  module HistoricalDataClient

    # View all of your balance ledger entries.
    #
    # @param currency [string] (optional) Specify the currency, default "USD"
    # @param params :since [time] (optional) Return only the history after this timestamp.
    # @param params :until [time] (optional) Return only the history before this timestamp.
    # @param params :limit [int] (optional) Limit the number of entries to return. Default is 500.
    # @param params  :wallet [string] (optional) Return only entries that took place in this wallet. Accepted inputs are: “trading”, “exchange”, “deposit”
    # @return [Array]
    # @example:
    #   client.history
    def history(currency="usd", params = {})
      check_params(params, %i{since until limit wallet})
      params.merge!({currency: currency})
      authenticated_post("history", params: params).body
    end

    # View your past deposits/withdrawals.
    #
    # @param currency [string] (optional) Specify the currency, default "USD"
    # @param params :method (optional) The method of the deposit/withdrawal (can be “bitcoin”, “litecoin”, “darkcoin”, “wire”)
    # @param params :since (optional) Return only the history after this timestamp
    # @param params :until [time] (optional) Return only the history before this timestamp.
    # @param params :limit [int] (optional) Limit the number of entries to return. Default is 500.
    # @return [Array]
    # @example:
    #   client.movements
    def movements(currency="usd", params = {})
      check_params(params, %i{method since until limit})
      params.merge!({currency: currency})
      authenticated_post("history/movements", params: params).body
    end

    # View your past trades.
    #
    # @param symbol The pair traded (BTCUSD, LTCUSD, LTCBTC)
    # @param params :until [time] (optional) Return only the history before this timestamp.
    # @param params :timestamp [time] (optional) Trades made before this timestamp won’t be returned
    # @param params :until [time] (optional) Trades made after this timestamp won’t be returned
    # @param params :limit_trades [int] Limit the number of trades returned. Default is 50.
    # @param params :reverse [int] Return trades in reverse order (the oldest comes first). Default is returning newest trades first.
    # @return [Array]
    # @example:
    #   client.mytrades
    def mytrades(symbol, params = {})
      check_params(params, %i{until limit_trades reverse timestamp})
      params.merge!({symbol: symbol})
      authenticated_post("mytrades", params: params).body
    end
  end
end
