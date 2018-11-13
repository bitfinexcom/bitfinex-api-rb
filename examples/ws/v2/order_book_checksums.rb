require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :manage_order_books => true
})

client.on(:order_book) do |sym, msg|
  p "recv order book message for symbol #{sym}"
  p msg
end

client.on(:open) do
  client.subscribe_order_book('tBTCUSD', 'P0', '25')
  client.enable_ob_checksums
end

client.open!