require 'httparty'

module Bitfinexrb
  # main
  class Base
    include HTTParty

    base_uri 'https://api.bitfinex.com/v1'
  end
end

require 'bitfinexrb/ticker'
require 'bitfinexrb/orderbook'
require 'bitfinexrb/trades'
require 'bitfinexrb/lends'
require 'bitfinexrb/lendbook'
require 'bitfinexrb/websocket'
