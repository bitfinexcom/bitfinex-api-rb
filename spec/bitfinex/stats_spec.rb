require "spec_helper"

describe Bitfinex::Client do
  include_context "api requests"

  let(:stats) { [
                   {"period"=>1, "volume"=>"26890.38714429"},
                   {"period"=>7, "volume"=>"135897.00085029"},
                   {"period"=>30, "volume"=>"761731.76256703"},
                ] }
  let(:json_stats) { stats.to_json }

  before do
    stub_http("/stats/btcusd", json_stats)
    @stats = client.stats("btcusd")
  end

  it { expect(@stats.size).to eq(3) }
  it { expect(@stats[1]["period"]).to eq(7) }
  it { expect(@stats[2]["volume"]).to eq("761731.76256703") }

end

