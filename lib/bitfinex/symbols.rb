module Bitfinex

  module SymbolsClient
    def symbols
      resp = get("symbols")
      resp.body
    end

    def symbols_details
      resp = get("symbols_details")
      resp.body
    end 
  end

end
