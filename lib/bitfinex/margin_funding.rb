module Bitfinex
  module MarginFundingClient

    def new_offer(currency, amount, rate, period, direction)
      params = { 
        currency: currency,
        amount: amount, 
        rate: rate,
        period: period,
        direction: direction
      }

      authenticated_post("offer/new", params).body
    end

		def cancel_offer(offer_id)
      authenticated_post("offer/cancel", {offer_id: offer_id}).body
		end	

		def offer_status(offer_id)
      authenticated_post("offer/status", {offer_id: offer_id}).body
    end

    def credits
      authenticated_post("credits").body
    end

    def offers
      authenticated_post("offers").body
    end

    def taken_funds
      authenticated_post("taken_funds").body
    end

    def unused_taken_funds
      authenticated_post("unused_taken_funds").body
    end

    def total_taken_funds
      authenticated_post("total_taken_funds").body
    end

    def close_funding(swap_id)
      authenticated_post("funding/close", {swap_id: swap_id}).body
    end
  end
end
