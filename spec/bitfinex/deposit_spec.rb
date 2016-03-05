require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  let(:deposit) { {
      "result":"success",
      "method":"bitcoin",
      "currency":"BTC",
      "address":"xyz"
    } }
  let(:json_deposit) { deposit.to_json }

  before do
    stub_http("/deposit/new",json_deposit , method: :post)
    @deposit = client.deposit("bitcoin", "exchange")
  end

  it {expect(@deposit["result"]).to eq("success") }
end
