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
end

client.on(:notification) do |n|
  puts 'received notification: %s' % [n]
end

client.open!