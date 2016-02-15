require "spec_helper"

describe Bitfinex::Client do

  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:ticker) { {"mid"=>"403.99", 
                  "bid"=>"403.98", 
                  "ask"=>"404.0", 
                  "last_price"=>"403.98", 
                  "low"=>"394.16", 
                  "high"=>"412.5", 
                  "volume"=>"28987.53907309", 
                  "timestamp"=>"1455526882.874391121"} 
               }

  let(:json_ticker) { ticker.to_json }

  let(:client) { Bitfinex::Client.new }
  context "correct JSON response" do
    before do
      stub_request(:get, "http://apitest/pubticker/btcusd").
        to_return(status: 200, headers: headers, body: json_ticker)
      @ticker = client.ticker("btcusd")
    end

    it { expect(@ticker.mid).to eq("403.99") }
    it { expect(@ticker.bid).to eq("403.98") }
  end

  context "malformed response JSON" do
    before do
      stub_request(:get, "http://apitest/pubticker/btcusd").
        to_return(status: 200, headers: headers, body: "malformed json")
    end

    it { expect{ client.ticker }.to raise_error(Faraday::ParsingError) }
  end

  context "400 error" do
    before do
      stub_request(:get, "http://apitest/pubticker/btcusd").
        to_return(status: 400, body: "error!")
    end

    it { expect{ client.ticker }.to raise_error(Faraday::ClientError) }
  end
end

