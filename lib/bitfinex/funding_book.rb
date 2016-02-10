module Bitfinex

  module FundingBookClient
    FUNDING_BOOK_ALLOWED_PARAMS = %i{limit_bids limit_asks}

    def funding_book(currency, params = {})
      resp = rest.get("/lendbook/#{currency}", check_params(params, FUNDING_BOOK_ALLOWED_PARAMS))
      resp.body.map do |book|
        FundingBook.new(book)
      end
    end
  end

  class FundingBook < BaseResource
    set_properties :bids, :asks
  end
end
