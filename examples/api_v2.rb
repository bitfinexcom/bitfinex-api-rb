require_relative '../lib/bitfinex-api-rb.rb'

# Configure the client with the proper KEY/SECRET, you can create a new one from:
# https://www.bitfinex.com/api
Bitfinex::Client.configure do |conf|
  conf.api_key = ENV["BFX_KEY"]
  conf.secret  = ENV["BFX_SECRET"]
  # this helper set the API version 2
  conf.use_api_v2
end

client = Bitfinex::Client.new
puts client.ticker("tBTCUSD","tLTCUSD","fUSD")
