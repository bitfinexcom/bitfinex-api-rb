require "spec_helper"

describe Bitfinex::TradesClient do

  let(:headers) { { 'Content-Type' => 'text/json' } }
  let(:trades) { [{tid: 1, price: 10.30},{tid:2, price: 10.40}] }

  let(:json_trades ) { trades.to_json }

  let(:client) { Bitfinex::Client.new }

  describe ".trades" do

    context "passing the right params" do
      before do
        stub_request(:get, "http://apitest/trades/btcusd?limit_trades=10").
          to_return(status: 200, headers: headers, body: json_trades)
        @trades = client.trades("btcusd", limit_trades: 10)
      end

      it { expect(@trades.size).to eq(2) }
      it { expect(@trades[0].tid).to eq(1) }
    end
    

    context "passing the wrong params" do
      before do
        stub_request(:get, "http://apitest/trades/btcusd").
          to_return(status: 200, headers: headers, body: json_trades)
      end

      it {expect{client.trades("btcusd", wrong_param: 10)}.to raise_error(Bitfinex::ParamsError) }
    end
  end
end

