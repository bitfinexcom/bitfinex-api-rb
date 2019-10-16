require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv2.new({
  :url => ENV['REST_URL'],
  :proxy => ENV['PROXY'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

o = Bitfinex::Models::Order.new({
  :type => 'EXCHANGE LIMIT',
  :price => 14750,
  :amount => 1,
  :symbol => 'tBTCUSD'
})

puts client.submit_order(o)
