module Bitfinex

  module SymbolsClient
    def symbols
      resp = get("symbols")
      resp.body.map do |sym|
        Symbol.new(pair: sym)
      end
    end

    def symbols_details
      resp = get("symbols_details")
      resp.body.map do |sym|
        Symbol.new(sym)
      end
    end 
  end

  class Symbol < BaseResource
    set_properties :pair, :price_precision, :initial_margin, :minimum_margin, :minimum_order_size, :maximum_order_size, :expiration 
  end
end
