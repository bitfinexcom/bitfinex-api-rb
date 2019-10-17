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

# submit an order
print client.submit_order(o)
# update an order
print client.update_order({ :id => 1185657359, :price => '14730' })
# cancel an order
print client.cancel_order({ :id => 1185657349 })
