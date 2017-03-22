require 'bitfinex-api-rb'

# Configure the client with the proper KEY/SECRET, you can create a new one from:
# https://www.bitfinex.com/api
Bitfinex::Client.configure do |conf|
  conf.api_key = ENV["BFX_KEY"]
  conf.secret  = ENV["BFX_SECRET"]
  conf.websocket_api_endpoint = "wss://api.bitfinex.com/ws"
end

client = Bitfinex::Client.new
pair = "ETHUSD"

# Documentation: https://bitfinex.readme.io/reference#ws-public-ticker
#
# Array comes with the following values:
#  1  BID   float   Price of last highest bid
#  2  BID_SIZE  float   Size of the last highest bid
#  3  ASK   float   Price of last lowest ask
#  4  ASK_SIZE  float   Size of the last lowest ask
#  5  DAILY_CHANGE  float   Amount that the last price has changed since yesterday
#  6  DAILY_CHANGE_PERC   float   Amount that the price has changed expressed in percentage terms
#  7  LAST_PRICE  float   Price of the last trade.
#  8  VOLUME  float   Daily volume
#  9  HIGH  float   Daily high
#  10 LOW   float   Daily low
#
# configure the listener:
client.listen_ticker(pair) do |tick|
  puts "Last Price: #{tick[7]}\t High: #{tick[9]}\t Low: #{tick[10]}"
end

puts "Bitfinex Ticker Price for #{pair}:"
client.listen!
