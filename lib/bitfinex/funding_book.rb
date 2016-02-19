module Bitfinex
  module FundingBookClient
    def funding_book(currency="btcusd", params = {})
      check_params(params, %i{limit_bids limit_asks})
      get("lendbook/#{currency}", params).body
    end
  end
end
