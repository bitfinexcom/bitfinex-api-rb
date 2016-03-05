require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  let(:response) { [ { "type": "depsit", "amount": "10.0"} ] }

  context ".balances" do
    before do 
      stub_http("/balances", response.to_json, method: :post)
      @response = client.balances
    end

    it {expect(@response.size).to eq(1)}
  end

  context "margin_info" do
    before do 
      stub_http("/margin_info", response.to_json, method: :post)
      @response = client.margin_info
    end

    it {expect(@response.size).to eq(1)}
  end

  context "transfer" do
    before do 
      stub_http("/transfer", response.to_json, method: :post)
      @response = client.transfer(100, "USD", 1000,1001)
    end

    it {expect(@response.size).to eq(1)}
  end

  context "withdraw" do
    before do 
      stub_http("/withdraw", response.to_json, method: :post)
      @response = client.withdraw("bitcoin", "deposit", 10, address: "bitcoin address")
    end

    it {expect(@response.size).to eq(1)}
  end

  context "key_info" do
    before do 
      stub_http("/key_info", response.to_json, method: :post)
      @response = client.key_info
    end

    it {expect(@response.size).to eq(1)}
  end
end
