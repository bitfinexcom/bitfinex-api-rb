module Bitfinex

  module PositionsClient

    def positions
      authenticated_post("positions").body
    end

    def claim_position(position_id, amount)
      authenticated_post("position/claim", {position_id: position_id, amount: amount}).body
    end
  end
end
