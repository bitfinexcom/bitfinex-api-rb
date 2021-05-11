module Bitfinex
  module RESTv2Margin

    # Get active offers
    #
    # @example:
    #    client.offers
    def offers(symbol)
      authenticated_post("auth/r/funding/offers/#{symbol}").body
    end

    # Get account margin info
    # - if symbol is not specified return everything
    #
    # @param symbol [string] (optional)
    #
    # @example:
    #   client.margin_info("tBTCUSD")
    def margin_info(symbol = "base")
      authenticated_post("auth/r/info/margin/#{symbol}").body
    end

    # Get account funding info
    #
    # @param symbol [string] default fUSD
    #
    # @example:
    #   client.funding_info
    def funding_info(symbol = "fUSD")
      authenticated_post("auth/r/info/funding/#{symbol}").body
    end
  end
end
