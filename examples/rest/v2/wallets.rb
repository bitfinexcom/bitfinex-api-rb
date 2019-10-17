require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv2.new({
  :url => ENV['REST_URL'],
  :proxy => ENV['PROXY'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

# print all wallets
puts client.wallets
# print bitcoin deposit address
puts client.deposit_address('exchange', 'bitcoin')
# create/print new deposit address
puts client.create_deposit_address('exchange', 'bitcoin')
