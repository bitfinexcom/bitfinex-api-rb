require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :manage_order_books => true
})

client.on(:open) do
  client.subscribe_order_book('tBTCUSD', 'P0', '25')
  client.enable_sequencing
end

client.open!