require "spec_helper"

describe Bitfinex::Client do

  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:lends) { 
                [{
                  "rate":"9.8998",
                  "amount_lent":"22528933.77950878",
                  "amount_used":"0.0",
                  "timestamp":1444264307
                }]
							}	

  let(:json_lends) { lends.to_json }

  let(:client) { Bitfinex::Client.new }

  before do
    stub_request(:get, "http://apitest/lends/btcusd").
      to_return(status: 200, headers: headers, body: json_lends)
    @lends = client.lends("btcusd")
  end

  it { expect(@lends.size).to eq(1) }
  it { expect(@lends[0]['amount_lent']).to eq("22528933.77950878") }

end

