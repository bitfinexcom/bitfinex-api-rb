module Bitfinex
  module FundingBookClient

    # Get the full margin funding book

    # @param currency [string] (optional) Speficy the currency, default "USD"
    # @param params :limit_bids [int] (optional) Limit the number of funding bids returned. May be 0 in which case the array of bids is empty.
    # @param params :limit_asks [int] (optional) Limit the number of funding offers returned. May be 0 in which case the array of asks is empty.
    # @return [Hash] of :bids and :asks arrays
    # @example:
    #   client.funding_book
    def funding_book(currency="usd", params = {})
      check_params(params, %i{limit_bids limit_asks})
      get("lendbook/#{currency}", params: params).body
    end

  end
end
