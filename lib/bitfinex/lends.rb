module Bitfinex

	module LendsClient 
		LEND_ALLOWD_PARAMS = %i{timestamp limit_lends}

		def lends(currency = "btcusd", params = {})
			resp = get("lends/#{currency}", check_params(params, LEND_ALLOWD_PARAMS))
			resp.body.map do |lend|
				Lend.new(lend)
			end	
		end
	end

	class Lend < BaseResource
		set_properties :rate, :amount_lent, :amount_used, :timestamp
	end
end
