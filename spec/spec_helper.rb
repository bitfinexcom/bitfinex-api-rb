require "simplecov"
SimpleCov.start
require 'webmock/rspec'
require 'pry'
require File.dirname(__FILE__) + '/../lib/bitfinex.rb'

RSpec.configure do |config|
  config.before(:each) do
    Bitfinex::Client.configure do |client_conf|
      client_conf.api_endpoint = "http://apitest"
    end
  end
end
