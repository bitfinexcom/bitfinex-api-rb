require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :transform => true
})

client.on(:candles) do |key, msg|
  p "recv candle message for key #{key}"

  if msg.kind_of?(Array)
    p msg.map { |c| c.serialize.join('|') }
  else
    p msg.serialize.join('|')
  end
end

client.on(:open) do
  client.subscribe_candles('trade:1m:tBTCUSD')
end

client.open!