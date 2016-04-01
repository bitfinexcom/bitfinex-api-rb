require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  context "malformed response JSON" do
    before do
      stub_http("/pubticker/btcusd","malformed json")
    end

    it { expect{ client.ticker }.to raise_error(Faraday::ParsingError) }
  end

  context "400 error" do
    before do
      stub_http("/pubticker/btcusd",{message: "error message 400"}.to_json,status: 400)
    end

    it { expect{ client.ticker }.to raise_error(Bitfinex::ServerError) }
  end


  context "500 error" do
    before do
      stub_http("/pubticker/btcusd",{message: "error message 500"}.to_json, status:500)
    end

    it { expect{ client.ticker }.to raise_error(Bitfinex::ServerError, "error message 500") }
  end

end
