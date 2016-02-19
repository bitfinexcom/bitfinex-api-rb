module Bitfinex
  module LendsClient 
    def lends(currency = "btcusd", params = {})
      check_params(params, %i{timestamp limit_lends})
      get("lends/#{currency}", params).body
    end
  end
end
