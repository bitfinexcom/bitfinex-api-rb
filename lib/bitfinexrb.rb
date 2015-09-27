require 'httparty'

module Bitfinexrb
  # main
  class Base
    include HTTParty

    base_uri 'https://api.bitfinex.com/v1'
  end

  # authenticated
  class Authenticated
    include HTTParty
    format :json
    base_uri 'https://api.bitfinex.com'

    attr_accessor :key, :secret

    def initialize
      @api_version = 'v1'
      @key = ENV['BFX_KEY']
      @secret = ENV['BFX_SECRET']
    end

    def headers_for(url, options = {})
      payload = {}
      payload['request'] = url
      payload['nonce'] = (Time.now.to_f * 10_000).to_i.to_s
      payload.merge!(options)

      payload_enc = Base64.encode64(payload.to_json).gsub(/\s/, '')
      sig = Digest::HMAC.hexdigest(payload_enc, @secret, Digest::SHA384)

      { 'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'X-BFX-APIKEY' => @key,
        'X-BFX-PAYLOAD' => payload_enc,
        'X-BFX-SIGNATURE' => sig
      }
    end
  end
end

require 'bitfinexrb/pairs'
require 'bitfinexrb/ticker'
require 'bitfinexrb/orderbook'
require 'bitfinexrb/trades'
require 'bitfinexrb/lends'
require 'bitfinexrb/lendbook'
require 'bitfinexrb/positions'
require 'bitfinexrb/orders'
require 'bitfinexrb/balances'
require 'bitfinexrb/margin_info'
require 'bitfinexrb/credits'
require 'bitfinexrb/taken_funds'
require 'bitfinexrb/account_info'
require 'bitfinexrb/websocket'
