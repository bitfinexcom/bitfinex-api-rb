module Bitfinex
  module LendsClient

    # Get a list of the most recent funding data for the given currency: total amount provided and Flash Return Rate (in % by 365 days) over time.
    #
    # @param currency [string] (optional) Specify the currency, default "USD"
    # @param params :timestamp [time] (optional) Only show data at or after this timestamp
    # @param params :limit_lends [int] (optional) Limit the amount of funding data returned. Must be > 1, default 50
    # @return [Array]
    # @example:
    #   client.lends
    def lends(currency = "usd", params = {})
      check_params(params, %i{timestamp limit_lends})
      get("lends/#{currency}", params: params).body
    end

  end
end
