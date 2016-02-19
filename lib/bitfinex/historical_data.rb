module Bitfinex
  module HistoricalDataClient
    def history(currency="usd", params = {})
      check_params(params, %i{since until limit wallet}) 
      params.merge!({currency: currency})
      authenticated_post("history", params).body
    end

    def movements(currency="usd", params = {})
      check_params(params, %i{method since until limit})
      params.merge!({currency: currency})
      authenticated_post("history/movements", params).body
    end

    def mytrades(symbol, params = {})
      check_params(params, %i{until limit_trades reverse timestamp})
      params.merge!({symbol: symbol})
      authenticated_post("mytrades", params).body
    end
  end
end
