require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  context "account_info" do

    let(:account_info) { [{
        "maker_fees"=>"0.1",
        "taker_fees"=>"0.2",
        "fees"=>[
            {"pairs"=>"BTC", "maker_fees"=>"0.1", "taker_fees"=>"0.2"},
            {"pairs"=>"LTC", "maker_fees"=>"0.1", "taker_fees"=>"0.2"},
            {"pairs"=>"DRK", "maker_fees"=>"0.1", "taker_fees"=>"0.2"}]}
        ] }
    let(:json_account_info) { account_info.to_json }

    before do
      stub_http("/account_infos",json_account_info, method: :post)
      @account_info = client.account_info
    end

    it {expect(@account_info[0]["maker_fees"]).to eq("0.1") }
    it {expect(@account_info[0]["fees"].size).to eq(3) }
  end

  context "fees" do
    let(:fees) {
      {
        "withdraw":{
          "BTC": "0.0005"
        }
      }
    }
    let(:json_fees) { fees.to_json }

    before do
      stub_http("/fees",json_fees, method: :post)
      @fees = client.fees
    end

    it {expect(@fees["withdraw"]["BTC"]).to eq("0.0005") }
  end
end
