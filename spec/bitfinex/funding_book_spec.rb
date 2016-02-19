require "spec_helper"

describe Bitfinex::Client do
  include_context "api requests"

  let(:funding_book) { {
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
   } }

  let(:json_funding_book) { funding_book.to_json }

  before do
    stub_http("/lendbook/btcusd", json_funding_book)
    @funding_book = client.funding_book("btcusd")
  end

  it { expect(@funding_book['asks'].size).to eq(1) }
  it { expect(@funding_book['bids'][0]['rate']).to eq("9.1287") }

end

