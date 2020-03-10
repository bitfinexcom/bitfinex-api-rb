# frozen_String_literal: true

module Bitfinex
  # RESTv2 utility methods
  module RESTv2Utils
    # Calculate the average execution rate for Trading or Margin funding.
    #
    # @param symbol [String]
    # @param amount [Numeric] Positive for buy, negative for sell (ex. "1.123")
    # @param period [Numeric] Maximum period for Margin Funding
    # @param rate_limit [String] Limit rate/price (ex. "1000.5")
    #
    # @return [Array]
    #
    # @example:
    #   client.calc_avg_price('tBTCUSD', 1000, 1000)
    def calc_avg_price(
      symbol = 'tBTCUSD', amount = 0, period = 0, rate_limit = nil
    )
      params = {
        symbol: symbol,
        amount: amount.to_s,
        period: period.to_s
      }
      params[:rateLimit] = rate_limit.to_s unless rate_limit.nil?
      get('calc/trade/avg', params)
    end
  end
end
