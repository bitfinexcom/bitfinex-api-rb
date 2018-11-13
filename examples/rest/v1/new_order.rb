require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv1.new({
  :url => ENV['REST_URL'],
  :proxy => ENV['PROXY'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

puts client.new_order('btcusd', 0.1, 'limit', 'sell', 15_000, {
  :is_hidden => true
})
