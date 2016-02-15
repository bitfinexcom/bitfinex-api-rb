require "spec_helper"

describe Bitfinex::Client do

  let(:headers) { { 'Content-Type' => 'application/json' } }
  let(:stats) { [
                       {"period"=>1, "volume"=>"26890.38714429"},
                       {"period"=>7, "volume"=>"135897.00085029"},
                       {"period"=>30, "volume"=>"761731.76256703"},
  ] }

  let(:json_stats) { stats.to_json }

  let(:client) { Bitfinex::Client.new }

  before do
    stub_request(:get, "http://apitest/stats/btcusd").
      to_return(status: 200, headers: headers, body: json_stats)
    @stats = client.stats("btcusd")
  end

  it { expect(@stats.size).to eq(3) }
  it { expect(@stats[1]["period"]).to eq(7) }
  it { expect(@stats[2]["volume"]).to eq("761731.76256703") }

end

