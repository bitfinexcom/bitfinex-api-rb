require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  let(:response) { {
    "id":13800585,
    "currency":"USD" 
  } }

  context ".new_offer" do
    before do
      stub_http("/offer/new", response.to_json, method: :post)
      @response = client.new_offer("USD",1000, 10, 2,:lend)
    end

    it {expect(@response["id"]).to eq(13800585)}
  end

  context ".cancel_offer" do
    before do
      stub_http("/offer/cancel", response.to_json, method: :post)
      @response = client.cancel_offer(13800585)
    end
    it {expect(@response["id"]).to eq(13800585)}
  end

  context ".offer_status" do
    before do
      stub_http("/offer/status", response.to_json, method: :post)
      @response = client.offer_status(13800585)
    end
    it {expect(@response["id"]).to eq(13800585)}
  end

  context ".credits" do
    before do
      stub_http("/credits", [response].to_json, method: :post)
      @response = client.credits
    end
    it {expect(@response[0]["id"]).to eq(13800585)}
  end
  
  context ".offers" do
    before do
      stub_http("/offers", [response].to_json, method: :post)
      @response = client.offers
    end
    it {expect(@response[0]["id"]).to eq(13800585)}
  end

  context ".taken_funds" do
    before do
      stub_http("/taken_funds", [response].to_json, method: :post)
      @response = client.taken_funds
    end
    it {expect(@response[0]["id"]).to eq(13800585)}
  end

  context ".unused_taken_funds" do
    before do 
      stub_http("/unused_taken_funds", [response].to_json, method: :post)
      @response = client.unused_taken_funds
    end
    it {expect(@response[0]["id"]).to eq(13800585)}
  end

  context ".total_taken_funds" do
    before do 
      stub_http("/total_taken_funds", [response].to_json, method: :post)
      @response = client.total_taken_funds
    end
    it {expect(@response[0]["id"]).to eq(13800585)}
  end

  context ".close_funding" do
    before do 
      stub_http("/funding/close", response.to_json, method: :post)
      @response = client.close_funding(1000)
    end
    it {expect(@response["id"]).to eq(13800585)}
  end
   

end

