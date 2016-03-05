require "simplecov"
SimpleCov.start
require 'webmock/rspec'
require File.dirname(__FILE__) + '/../lib/bitfinex.rb'
Dir[File.dirname(__FILE__) + '/contexts/*rb'].each {|file| require file; puts file }

RSpec.configure do |config|
  config.before(:each) do
    Bitfinex::Client.configure do |client_conf|
      client_conf.api_endpoint = "http://apitest"
      client_conf.api_key = "test_key"
      client_conf.secret  = "secret"
    end
  end
end
