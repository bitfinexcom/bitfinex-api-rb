module Bitfinex

  module AccountInfoClient 
    def account_info
      resp = authenticated_post("account_infos")
      resp.body.map do |info|
        AccountInfo.new(info)
      end
    end
  end

  class AccountInfo < BaseResource
    set_properties :maker_fees, :taker_fees, :fees
  end

end
