module Bitfinex
  module PositionsClient

    # View your active positions.
    #
    # @return [Array]
    # @example:
    #   client.positions
    def positions
      authenticated_post("positions").body
    end

    # A position can be claimed if:
    #
    # It is a long position: The amount in the last unit of the position pair that you have in your trading wallet AND/OR the realized profit of the position is greater or equal to the purchase amount of the position (base price * position amount) and the funds which need to be returned. For example, for a long BTCUSD position, you can claim the position if the amount of USD you have in the trading wallet is greater than the base price * the position amount and the funds used.
    #
    # It is a short position: The amount in the first unit of the position pair that you have in your trading wallet is greater or equal to the amount of the position and the margin funding used.
    # @param position_id [int] The position ID given by `/positions`
    # @param amount [decimal] The partial amount you wish to claim
    # @return [Hash]
    # @example:
    #    client.claim_position(100,10)
    def claim_position(position_id, amount)
      authenticated_post("position/claim", params: {position_id: position_id, amount: amount}).body
    end
  end
end
