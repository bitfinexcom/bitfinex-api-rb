require "spec_helper"

describe Bitfinex::Client do
  include_context "api requests"

  let(:trades) { [{
    "timestamp"=>1455527016,
     "tid"=>15627115,
     "price"=>"403.97",
     "amount"=>"0.5",
     "exchange"=>"bitfinex",
     "type"=>"buy"
    },{
     "timestamp"=>1455526974,
     "tid"=>15627111,
     "price"=>"404.01",
     "amount"=>"2.45116479",
     "exchange"=>"bitfinex",
     "type"=>"sell"
  }]}

  describe ".trades" do

    context "passing the right params" do
      before do
        stub_http("/trades/btcusd?limit_trades=10", trades.to_json)
        @trades = client.trades("btcusd", limit_trades: 10)
      end

      it { expect(@trades.size).to eq(2) }
      it { expect(@trades[0]["tid"]).to eq(15627115) }
    end


    context "passing the wrong params" do
      before do
        stub_http("/trades/btcusd",trades.to_json)
      end

      it {expect{client.trades("btcusd", wrong_param: 10)}.to raise_error(Bitfinex::ParamsError) }
    end
  end
end
