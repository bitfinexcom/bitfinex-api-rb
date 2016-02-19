module Bitfinex

	module LendsClient 
		LEND_ALLOWD_PARAMS = %i{timestamp limit_lends}

		def lends(currency = "btcusd", params = {})
			resp = get("lends/#{currency}", check_params(params, LEND_ALLOWD_PARAMS))
      resp.body
		end
	end
end
