# frozen_string_literal: true

module Bitfinex
  # RESTv1 lends API interface
  module RESTv1Lends
    # Get a list of the most recent funding data for the given currency: total
    # amount provided and Flash Return Rate (in % by 365 days) over time.
    #
    # @param currency [string?] Specify the currency, default "USD"
    # @param params [Hash]
    # @option params [Date?] :timestamp start time of data to return
    # @option params [Number?] :limit_lends > 1, default 50
    # @return [Array]
    # @example:
    #   client.lends
    def lends(currency = 'usd', params = {})
      check_params(params, %i[timestamp limit_lends])
      get("lends/#{currency}", params: params).body
    end
  end
end
