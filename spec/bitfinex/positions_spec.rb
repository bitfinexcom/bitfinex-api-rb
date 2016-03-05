require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  context ".positions" do
    let(:response){
      [{
        "id":943715,
        "symbol":"btcusd",
      },{
        "id":943716,
        "symbol":"btcusd",
      }]
    }

    before do
      stub_http("/positions", response.to_json, method: :post)
      @response = client.positions
    end

    it {expect(@response.size).to eq(2)}
    it {expect(@response[0]["id"]).to eq(943715)}
  end

  context ".claim_position" do
    let(:response){
      {
        "id":943715,
        "symbol":"btcusd",
      }
    }

    before do
      stub_http("/position/claim", response.to_json, method: :post)
      @response = client.claim_position(943715, 10)
    end

    it {expect(@response["id"]).to eq(943715)}
  end
end

