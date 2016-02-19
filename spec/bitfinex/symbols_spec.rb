require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  let(:symbols) { ["btcusd","ltcusd","ltcbtc"] }
  let(:symbols_details) { 
    [{
      "pair":"btcusd",
      "price_precision":5,
      "initial_margin":"30.0",
      "minimum_margin":"15.0",
      "maximum_order_size":"2000.0",
      "minimum_order_size":"0.01",
      "expiration":"NA"
    },{
      "pair":"ltcusd",
      "price_precision":5,
      "initial_margin":"30.0",
      "minimum_margin":"15.0",
      "maximum_order_size":"5000.0",
      "minimum_order_size":"0.1",
      "expiration":"NA"
    },{
      "pair":"ltcbtc",
      "price_precision":5,
      "initial_margin":"30.0",
      "minimum_margin":"15.0",
      "maximum_order_size":"5000.0",
      "minimum_order_size":"0.1",
      "expiration":"NA"
    }]
  }


  describe ".symbols" do
    before do
      stub_http("/symbols", symbols.to_json)
      @symbols = client.symbols
    end

    it { expect(@symbols.size).to eq(3) }
    it { expect(@symbols[0]).to eq("btcusd") }
  end

  describe ".symbols_details" do
    before do
      stub_http("/symbols_details",symbols_details.to_json)
      @symbols = client.symbols_details
    end

    it { expect(@symbols.size).to eq(3) }
    it { expect(@symbols[0]["pair"]).to eq("btcusd") }
    it { expect(@symbols[0]["price_precision"]).to eq(5) }
  end
end

