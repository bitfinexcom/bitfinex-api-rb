require 'spec_helper'
require 'webmock/rspec'
require 'hashdiff'
require_relative '../../lib/bitfinex'

RSpec.describe 'Bitfinex::RESTv1 Integration' do
  before do
    # Stub the account info request
    stub_request(:post, "https://api.bitfinex.com/v1/account_infos")
      .with(body: '{}')
      .to_return(
        status: 200,
        body: '[
          {
            "leo_fee_disc_c2c":"0.0",
            "leo_fee_disc_c2s":"0.0",
            "leo_fee_disc_c2f":"0.0",
            "leo_fee_disc_c2d":"0.0",
            "leo_fee_disc_abs_c2c":"0.0",
            "leo_fee_disc_abs_c2s":"0.0",
            "leo_fee_disc_abs_c2f":"0.0",
            "leo_fee_disc_abs_c2d":"0.0",
            "leo_fee_maker_disc_abs_c2d":"0.0",
            "maker_fees":"0.1",
            "taker_fees":"0.2",
            "fees":[
              {"pairs":"BTC", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"ETH", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"IOT", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"XRP", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"REP", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"GRG", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"ZRX", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"MLN", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"SAN", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"AMP", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"DUSK", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"LNX", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"EOS", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"TESTBTC", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"TESTUSDT", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"TESTUSD", "maker_fees":"0.1", "taker_fees":"0.2"},
              {"pairs":"ETH2P", "maker_fees":"0.1", "taker_fees":"0.2"}
            ]
          }
        ]',
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub the account fees request
    stub_request(:post, "https://api.bitfinex.com/v1/account_fees")
      .with(body: '{}')
      .to_return(
        status: 200,
        body: '{"withdraw":{"BTC":"0.000001","ETH":"0.0","IOT":"0.0","XRP":"0.0","GRG":"0.025367","ZRX":"0.00000249","MLN":"0.00036065","SAN":"33.819","AMP":"5.3018","DUSK":"0.08371","LNX":"0.000001","EOS":"0.0","TESTBTC":"0.0","TESTUSDT":"0.0","TESTUSD":"0.0","EXO":"0.0","BMN":"0.0"}}',
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  let(:client) do
    Bitfinex::RESTv1.new({
      api_key: 'dummy_api_key',
      api_secret: 'dummy_api_secret',
      url: 'https://api.bitfinex.com',
    })
  end

  it 'fetches account info' do
    response = client.account_info
    expect(response).not_to be_nil
    expect(response).to be_a(Array)
    expect(response.first['maker_fees']).to eq('0.1')
    expect(response.first['taker_fees']).to eq('0.2')
    expect(response.first['fees']).to be_a(Array)
    expect(response.first['fees'].first['pairs']).to eq('BTC')
  end

  it 'fetches fees' do
    response = client.fees
    expect(response).not_to be_nil
    expect(response).to be_a(Hash)
    expect(response['withdraw']['BTC']).to eq('0.000001')
    expect(response['withdraw']['ETH']).to eq('0.0')
    expect(response['withdraw']['GRG']).to eq('0.025367')
  end
end
