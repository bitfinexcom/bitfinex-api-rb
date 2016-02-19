require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  let(:response) { [ { "type": "depsit", "amount": "10.0"} ] }

  before do 
	  stub_http("/balances", response.to_json, method: :post)
	  @response = client.balances
	end

  it {expect(@response.size).to eq(1)}
end
