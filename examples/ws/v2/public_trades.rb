require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
})

client.on(:public_trades) do |sym, msg|
  puts "recv public trades message for symbol #{sym}"
  puts msg.join('|')
end

client.on(:open) do
  client.subscribe_trades('tBTCUSD')
end

client.open!