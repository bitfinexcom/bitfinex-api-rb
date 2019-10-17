require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv2.new({
  :url => ENV['REST_URL'],
  :proxy => ENV['PROXY'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

o = Bitfinex::Models::FundingOffer.new({
  :type => 'LIMIT',
  :symbol => 'fUSD',
  :amount => 100,
  :rate => 0.002,
  :period => 2
})

# Submit an offer
print client.submit_funding_offer(o)
# Cancel and offer
print client.cancel_funding_offer(41236686)

# Request auto funding
print client.submit_funding_auto('USD', 100, 2)
