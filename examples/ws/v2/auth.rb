require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET'],
  :transform => true
})

client.on(:open) do
  client.auth!
end

client.on(:auth) do
  p 'succesfully authenticated'
end

client.on(:notification) do |n|
  p 'received notification: %s' % [n]
end

client.on(:position_snapshot) do |positions|
  p 'recv position snapshot'
  positions.each do |pos|
    p pos.serialize
  end
end

client.open!