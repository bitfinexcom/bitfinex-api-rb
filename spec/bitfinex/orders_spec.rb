require "spec_helper"

describe Bitfinex::Client do

  let(:headers) { { 'Content-Type' => 'text/json' } }
  let(:ticker) { {mid: 10, bid: 10.30} }

  let(:json_ticker) { ticker.to_json }

  let(:client) { Bitfinex::Client.new }
  context "correct JSON response" do
    before do
      stub_request(:get, "http://apitest/pubticker/btcusd").
        to_return(status: 200, headers: headers, body: json_ticker)
      @ticker = client.ticker("btcusd")
    end

    it { expect(@ticker.mid).to eq(10) }
    it { expect(@ticker.bid).to eq(10.3) }
  end

  context "malformed response JSON" do
    before do
      stub_request(:get, "http://apitest/pubticker/btcusd").
        to_return(status: 200, headers: headers, body: "malformed json")
    end

    it { expect{ client.ticker }.to raise_error(Faraday::ParsingError) }
  end
end

