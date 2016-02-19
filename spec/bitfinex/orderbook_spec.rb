require "spec_helper"

describe Bitfinex::Client do
  include_context "api requests"

  let(:orderbook) { {
    "bids":[{
      "rate":"9.1287",
      "amount":"5000.0",
      "period":30,
      "timestamp":"1444257541.0",
      "frr":"No"
    }],
    "asks":[{
      "rate":"8.3695",
      "amount":"407.5",
      "period":2,
      "timestamp":"1444260343.0",
      "frr":"No"
    }]}}	

  let(:json_orderbook) { orderbook.to_json }

  before do
    stub_http("/book/btcusd",json_orderbook)
    @orderbook = client.orderbook("btcusd")
  end

  it { expect(@orderbook['asks'].size).to eq(1) }
  it { expect(@orderbook['bids'][0]['amount']).to eq("5000.0") }

end

