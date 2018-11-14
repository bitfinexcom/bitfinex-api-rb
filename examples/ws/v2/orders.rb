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

  o = Bitfinex::Models::Order.new({
    :type => 'EXCHANGE LIMIT',
    :price => 3.0152235,
    :amount => 2.0235235263262,
    :symbol => 'tEOSUSD'
  })

  client.submit_order(o) do |order_packet|
    p "recv order confirmation packet with ID #{order_packet.id}"

    client.update_order({
      :id => order_packet.id,
      :price => '3.0'
    }) do |update_packet|
      p "updated order #{update_packet.id} with price #{update_packet.price}"

      client.cancel_order(order_packet) do |canceled_order|
        p "canceled order with ID #{canceled_order[0]}"
      end
    end
  end
end

client.on(:notification) do |n|
  p 'received notification: %s' % [n.serialize.join('|')]
end

client.on(:order_new) do |msg|
  p 'recv order new: %s' % [msg]
end

client.open!