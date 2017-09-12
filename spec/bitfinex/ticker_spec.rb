require "spec_helper"

describe Bitfinex::V1::TickerClient do
  include_context "api requests"

  let(:ticker) { {
    "mid"=>"403.99",
    "bid"=>"403.98",
    "ask"=>"404.0",
    "last_price"=>"403.98",
    "low"=>"394.16",
    "high"=>"412.5",
    "volume"=>"28987.53907309",
    "timestamp"=>"1455526882.874391121"
  } }

  context "correct JSON response" do
    before do
      stub_http("/pubticker/btcusd",ticker.to_json)
      @ticker = client.ticker("btcusd")
    end

    it { expect(@ticker["mid"]).to eq("403.99") }
    it { expect(@ticker["bid"]).to eq("403.98") }
  end
end

describe Bitfinex::V2::TickerClient do
end

