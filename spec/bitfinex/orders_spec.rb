require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

  context ".new_order" do
    let(:new_order) {
      {
        "id":448364249,
        "symbol": "btcusd",
        "order_id":448364249
      }
    }

    before do
      stub_http("/order/new", new_order.to_json, method: :post)
      @new_order = client.new_order("btcusd",0.01, "exchange limit", "buy", 0.01)
    end

    it {expect(@new_order["symbol"]).to eq("btcusd")}
    it {expect(@new_order["order_id"]).to eq(448364249)}
  end

  context ".multiple_orders" do
    let(:multiple_orders) {
      {
        "order_ids":[{
          "id":448383727,
        },{
          "id":448383729,
        }],
        "status":"success"
      }
    } 

    let(:orders){ [{symbol: "btcusd", amount: 0.01, price: 0.01, side: "buy"},
                   {symbol: "btcusd", amount: 0.01, price: 0.01, side: "buy"}] }
    before do
      stub_http("/order/new/multi", multiple_orders.to_json, method: :post)
      @orders = client.multiple_orders(orders: orders)
    end

    it {expect(@orders["status"]).to eq("success")}
    it {expect(@orders["order_ids"].size).to eq(2)}

  end

  context ".cancel_order" do
    context "single ID" do
      let(:cancel_order){ { "id":446915287, "symbol":"btcusd" } }

      before do
        stub_http("/order/cancel", cancel_order.to_json, method: :post)
        @response = client.cancel_orders(446915287)
      end

      it {expect(@response["id"]).to eq(446915287)}
    end

    context "multiple ID" do
      let(:response){ {"result":"Orders cancelled"} }


      before do
        stub_http("/order/cancel/multi", response.to_json, method: :post)
        @response = client.cancel_orders([446915287, 123123123])
      end

      it {expect(@response["result"]).to eq("Orders cancelled")}
    end

    context "cancel all orders" do
      let(:response) {{"result":"All orders cancelled"}}

      before do
        stub_http("/order/cancel/all", response.to_json, method: :post)
        @response = client.cancel_orders
      end

      it {expect(@response["result"]).to eq("All orders cancelled")}
    end
  end
   

  context ".replace_order" do
    let(:response) {
      {
        "id":448411365,
        "symbol":"btcusd",
        "order_id":448411365
      }
    }
    before do
      stub_http("/order/cancel/replace",response.to_json, method: :post)
      @response = client.replace_order(448411365, "btcusd", 0.01, :limit, :buy, 0.01)
    end
    
    it { expect(@response["id"]).to eq(448411365) }
  end
 
  context ".order_status" do
    let(:response) { {
      "id":448411153,
      "symbol":"btcusd",
      "price":"0.01",
      "avg_execution_price":"0.0" } }

    before do
      stub_http("/order/status",response.to_json, method: :post)
      @response = client.order_status(448411153)
    end
    
    it { expect(@response["id"]).to eq(448411153) }
  end

  context ".orders" do
    let(:response) { [{"id":448411153, "price":"0.01"},
                      {"id":448411155, "price":"0.01"}] }

    before do
      stub_http("/orders",response.to_json, method: :post)
      @response = client.orders
    end
    
    it { expect(@response.size).to eq(2) }
    it { expect(@response[0]["id"]).to eq(448411153) }


  end


end
