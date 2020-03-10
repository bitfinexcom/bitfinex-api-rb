# frozen_string_literal: true

module Bitfinex
  # RESTv1 symbol methods
  module RESTv1Symbols
    # Get a list of valid symbol IDs.
    #
    # @return [Array]
    # @example:
    # client.symbols
    def symbols
      get('symbols').body
    end

    # Get detailed list of symbols
    #
    # @return [Array]
    # @example:
    # client.symbols_details
    def symbols_details
      get('symbols_details').body
    end
  end
end
