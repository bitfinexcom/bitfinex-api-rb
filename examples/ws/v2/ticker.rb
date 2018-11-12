require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
})

client.on(:ticker) do |symbol, msg|
  puts "recv ticker message for symbol #{symbol}"
  puts msg.join('|')
end

client.on(:open) do
  client.subscribe_ticker('tBTCUSD')
end

client.open!