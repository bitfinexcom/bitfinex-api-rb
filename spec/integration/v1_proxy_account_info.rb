require 'spec_helper'
require 'webmock/rspec'
require_relative '../../lib/bitfinex'

RSpec.describe 'Bitfinex::RESTv1 Proxy Integration' do
  before do
    stub_request(:post, "https://api.bitfinex.com/v1/account_infos")
      .with(body: '{}')
      .to_return(
        status: 200,
        body: '[{"maker_fees":"0.1","taker_fees":"0.2"}]',
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  let(:client) do
    Bitfinex::RESTv1.new({
      api_key: 'dummy_api_key',
      api_secret: 'dummy_api_secret',
      url: 'https://api.bitfinex.com',
      proxy: 'http://proxy.example.com:8080'
    })
  end

  it 'fetches account info through proxy' do
    response = client.account_info
    expect(response).not_to be_nil
    expect(response).to be_a(Array)
    expect(response.first['maker_fees']).to eq('0.1')
    expect(response.first['taker_fees']).to eq('0.2')

    # Verify that the request was made through the proxy
    expect(WebMock).to have_requested(:post, "https://api.bitfinex.com/v1/account_infos")
      .with(headers: { 'Proxy-Authorization' => 'Basic ' + Base64.encode64('proxy_user:proxy_pass').strip })
  end
end
