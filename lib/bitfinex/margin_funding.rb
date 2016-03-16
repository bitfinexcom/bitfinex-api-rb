module Bitfinex
  module MarginFundingClient

    # Submit a new offer
    #
    # @param currency [string] The name of the currency, es: 'USD'
    # @param amount [decimal] Offer size: how much to lend or borrow
    # @param rate [decimal] Rate to lend or borrow at. In percentage per 365 days. Set to 0 for FRR).
    # @param period [integer] Number of days of the funding contract (in days)
    # @param direction [string] Either “lend” or “loan”
    # @return [Hash]
    # @example:
    #   client.new_offer("btc", 10.0, 20, 365, "lend")
    def new_offer(currency, amount, rate, period, direction)
      params = {
        currency: currency,
        amount: amount.to_s,
        rate: rate.to_s,
        period: period.to_i,
        direction: direction
      }
      authenticated_post("offer/new", params: params).body
    end

    # Cancel an offer
    #
    # @param offer_id [int] The offer ID given by `#new_offer`
    # @return [Hash]
    # @example:
    #   client.cancel_offer(1000)
    def cancel_offer(offer_id)
      authenticated_post("offer/cancel", params: {offer_id: offer_id.to_i}).body
    end

    # Get the status of an offer. Is it active? Was it cancelled? To what extent has it been executed? etc.
    #
    # @param offer_id [int] The offer ID give by `#new_offer`
    # @return [Hash]
    # @example:
    #   client.offer_status(1000)
    def offer_status(offer_id)
      authenticated_post("offer/status", params: {offer_id: offer_id.to_i}).body
    end

    # View your funds currently taken (active credits)
    #
    # @return [Array]
    # @example:
    #   client.credits
    def credits
      authenticated_post("credits").body
    end

    # View your active offers
    #
    # @return  [Array] An array of the results of /offer/status for all your live offers (lending or borrowing
    # @example:
    #   client.offers
    def offers
      authenticated_post("offers").body
    end

    # View your funding currently borrowed and used in a margin position
    #
    # @return [Array] An array of your active margin funds
    # @example:
    #   client.taken_funds
    def taken_funds
      authenticated_post("taken_funds").body
    end

    # View your funding currently borrowed and not used (available for a new margin position).
    #
    # @return [Array] An array of your active unused margin funds
    # @example:
    #   client.unused_taken_funds
    def unused_taken_funds
      authenticated_post("unused_taken_funds").body
    end

    # View the total of your active funding used in your position(s).
    #
    # @return [Array] An array of your active funding
    # @example:
    #   client.total_taken_funds
    def total_taken_funds
      authenticated_post("total_taken_funds").body
    end

    # Allow you to close an unused or used taken fund
    #
    # @param swap_id [int] The ID given by `#taken_funds` or `#unused_taken_funds
    # @return [Hash]
    # @example:
    #   client.close_funding(1000)
    def close_funding(swap_id)
      authenticated_post("funding/close", params: {swap_id: swap_id.to_i}).body
    end
  end
end
