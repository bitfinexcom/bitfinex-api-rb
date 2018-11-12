require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
})

client.on(:candles) do |key, msg|
  puts "recv candle message for key #{key}"
  puts msg.join('|')
end

client.on(:open) do
  client.subscribe_candles('trade:1m:tBTCUSD')
end

client.open!