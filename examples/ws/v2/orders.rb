require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

client.on(:open) do
  client.auth!
end

client.on(:auth) do
  puts 'succesfully authenticated'

  o = Bitfinex::Models::Order.new({
    :type => 'EXCHANGE LIMIT',
    :price => 3.0152235,
    :amount => 2.0235235263262,
    :symbol => 'tEOSUSD'
  })

  client.submit_order(o)
end

client.on(:notification) do |n|
  puts 'received notification: %s' % [n]
end

client.on(:order_new) do |msg|
  puts 'recv order new: %s' % [msg]
end

client.open!