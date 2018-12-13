require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :transform => true
})

client.on(:ticker) do |symbol, msg|
  p "recv ticker message for symbol #{symbol}"
  p msg.serialize.join('|')
end

client.on(:open) do
  client.subscribe_ticker('tBTCUSD')
  client.subscribe_ticker('fUSD')
end

client.open!