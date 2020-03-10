# frozen_string_literal: true

require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::WSv2.new( # rubocop:disable Lint/UselessAssignment
  {
    url: ENV['WS_URL']
  }
)
