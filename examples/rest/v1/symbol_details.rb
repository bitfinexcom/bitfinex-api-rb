# frozen_string_literal: true

require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv1.new
puts client.symbols_details
