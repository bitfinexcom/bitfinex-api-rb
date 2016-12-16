require_relative "../lib/bitfinex.rb"

client = Bitfinex::Client.new

client.listen_ticker("ETHUSD") do |response|
  puts response.join(", ")
end

client.listen!
