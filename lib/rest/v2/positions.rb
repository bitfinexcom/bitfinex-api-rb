# frozen_string_literal: true

module Bitfinex
  # RESTv2 positions methods
  module RESTv2Positions
    ###
    # Claim an active position
    #
    # @param [Hash|Array|Position|number] position - must contain or be ID
    #
    # @return [Array] Raw notification
    ###
    def claim_position(position) # rubocop:disable Metrics/MethodLength
      if position.is_a?(Numeric)
        id = position
      elsif position.is_a?(Array)
        id = position[0]
      elsif position.instance_of?(Models::Position)
        id = position.id
      elsif position.is_a?(Hash)
        id = position[:id] || position['id']
      else
        raise Exception, 'tried to claim position with invalid ID'
      end
      authenticated_post('auth/w/position/claim', params: { id: id }).body
    end
  end
end
