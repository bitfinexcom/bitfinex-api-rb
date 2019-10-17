require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv2.new({
  :url => ENV['REST_URL'],
  :proxy => ENV['PROXY'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

o = Bitfinex::Models::Order.new({
  :type => 'LIMIT',
  :price => 8000,
  :amount => 0.1,
  :symbol => 'tBTCF0:USDF0',
  :lev => 4
})

# Submit an order
print client.submit_order(o)
# Update an order
print client.update_order({ :id => 1185657359, :price => '14730' })
# Cancel an order
print client.cancel_order({ :id => 1185657349 })
