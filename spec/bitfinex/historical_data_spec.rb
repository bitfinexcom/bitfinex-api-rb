require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  context ".history" do
    let(:response) {
      [{
        "currency":"USD",
      }] }

    before do
      stub_http("/history", response.to_json, method: :post)
      @response = client.history
    end

    it {expect(@response[0]["currency"]).to eq("USD")}
  end

  context ".movements" do
    let(:response) {
      [{
        "id":581183,
        "currency":"BTC",
      }] }

    before do
      stub_http("/history/movements", response.to_json, method: :post)
      @response = client.movements
    end

    it {expect(@response[0]["currency"]).to eq("BTC")}
  end

  context ".mytrades" do
    let(:response) {
      [{
        "price":"246.94",
      }] }

    before do
      stub_http("/mytrades", response.to_json, method: :post)
      @response = client.mytrades("usdbtc")
    end

    it {expect(@response[0]["price"]).to eq("246.94")}
  end
end
