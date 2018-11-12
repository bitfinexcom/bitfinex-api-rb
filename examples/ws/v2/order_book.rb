require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
})

client.on(:order_book) do |sym, msg|
  puts "recv order book message for symbol #{sym}"
  puts msg.join('|')
end

client.on(:open) do
  client.subscribe_order_book('tBTCUSD', 'R0', '25')
end

client.open!