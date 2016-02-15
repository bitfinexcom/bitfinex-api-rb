module Bitfinex

  module FundingBookClient
    FUNDING_BOOK_ALLOWED_PARAMS = %i{limit_bids limit_asks}

    def funding_book(currency="btcusd", params = {})
      resp = get("lendbook/#{currency}", check_params(params, FUNDING_BOOK_ALLOWED_PARAMS))
      FundingBook.new(resp.body)
    end
  end

  class FundingBook < BaseResource
    set_properties :bids, :asks
  end
end
