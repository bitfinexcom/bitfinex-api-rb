# frozen_string_literal: true

require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv1.new(
  {
    url: ENV['REST_URL'],
    proxy: ENV['PROXY']
  }
)

puts client.orderbook
