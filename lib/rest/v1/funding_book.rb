# frozen_string_literal: true

module Bitfinex
  # RESTv1 API funding book methods
  module RESTv1FundingBook
    # Get the full margin funding book
    #
    # @param currency [string] (optional) Speficy the currency, default "USD"
    # @param params [Hash]
    # @option params [int] :limit_bids
    # @option params [int] :limit_asks
    # @return [Hash] of :bids and :asks arrays
    # @example:
    #   client.funding_book
    def funding_book(currency = 'usd', params = {})
      check_params(params, %i[limit_bids limit_asks])
      get("lendbook/#{currency}", params: params).body
    end
  end
end
