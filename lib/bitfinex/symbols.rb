module Bitfinex
  module SymbolsClient
    def symbols
      get("symbols").body
    end

    def symbols_details
      get("symbols_details").body
    end 
  end
end
