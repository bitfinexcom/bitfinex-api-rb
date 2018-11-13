require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :transform => true
})

client.on(:order_book) do |sym, msg|
  p "recv order book message for symbol #{sym}"
  p msg.serialize
end

client.on(:open) do
  client.subscribe_order_book('tBTCUSD', 'R0', '25')
end

client.open!