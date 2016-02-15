require "spec_helper"

describe Bitfinex::Client do

  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:orderbook) { 
												{
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
													}]
												}
											}	

  let(:json_orderbook) { orderbook.to_json }

  let(:client) { Bitfinex::Client.new }

  before do
    stub_request(:get, "http://apitest/book/btcusd").
      to_return(status: 200, headers: headers, body: json_orderbook)
    @orderbook = client.orderbook("btcusd")
  end

  it { expect(@orderbook['asks'].size).to eq(1) }
  it { expect(@orderbook['bids'][0]['amount']).to eq("5000.0") }

end

