require 'spec_helper'
require 'webmock/rspec'
require_relative '../../lib/bitfinex'

RSpec.describe 'Bitfinex::RESTv2 Integration' do
  before do
    stub_request(:post, "https://api.bitfinex.com/v2/auth/r/orders")
      .with(body: '{}')
      .to_return(
        status: 200,
        body: '[{"id":12345,"symbol":"tBTCUSD","amount":"1.0"}]',
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  let(:client) do
    Bitfinex::RESTv2.new({
      api_key: 'dummy_api_key',
      api_secret: 'dummy_api_secret',
      url: 'https://api.bitfinex.com',
    })
  end

  it 'fetches orders' do
    response = client.orders
    expect(response).not_to be_nil
    expect(response).to be_a(Array)
    expect(response.first['id']).to eq(12345)
    expect(response.first['symbol']).to eq('tBTCUSD')
  end
end
