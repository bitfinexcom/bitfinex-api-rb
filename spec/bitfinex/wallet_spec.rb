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

  context "margin_infos" do
    before do
      stub_http("/margin_infos", response.to_json, method: :post)
      @response = client.margin_infos
    end

    it {expect(@response.size).to eq(1)}
  end

  context "summary" do
    let(:response) { '{"trade_vol_30d":[{"curr":"BTC","vol":11.88696022},{"curr":"LTC","vol":0.0},{"curr":"ETH","vol":0.1},{"curr":"Total (USD)","vol":5027.63}],"funding_profit_30d":[{"curr":"USD","amount":0.0},{"curr":"BTC","amount":0.0},{"curr":"LTC","amount":0.0},{"curr":"ETH","amount":0.0}],"maker_fee":0.001,"taker_fee":0.002}' }
    before do
      stub_http("/summary", response, method: :post)
      @response = client.summary
    end

    it {expect(@response['trade_vol_30d'][0]['vol']).to eq(11.88696022)}
  end

  context "transfer" do
    before do
      stub_http("/transfer", response.to_json, method: :post)
      @response = client.transfer(100, "USD", "1000", "1001")
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
