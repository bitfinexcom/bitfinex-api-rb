require 'spec_helper'

describe Bitfinex::Client do
  include_context "api requests"

	context ".new_order" do
		let(:new_order) {
			{
				"id":448364249,
				"symbol":"btcusd",
				"exchange":"bitfinex",
				"price":"0.01",
				"avg_execution_price":"0.0",
				"side":"buy",
				"type":"exchange limit",
				"timestamp":"1444272165.252370982",
				"is_live":true,
				"is_cancelled":false,
				"is_hidden":false,
				"was_forced":false,
				"original_amount":"0.01",
				"remaining_amount":"0.01",
				"executed_amount":"0.0",
				"order_id":448364249
			}
		}

		before do
			stub_http("/order/new", new_order.to_json, method: :post)
			@new_order = client.new_order("btcusd",0.01, "exchange limit", "buy", 0.01, exchange: "bitfinex")
		end

		it {expect(@new_order["symbol"]).to eq("btcusd")}
		it {expect(@new_order["order_id"]).to eq(448364249)}
	end

	context ".multiple_orders" do
		let(:multiple_orders) {
			{
				"order_ids":[{
					"id":448383727,
					"symbol":"btcusd",
					"exchange":"bitfinex",
					"price":"0.01",
					"avg_execution_price":"0.0",
					"side":"buy",
					"type":"exchange limit",
					"timestamp":"1444274013.621701916",
					"is_live":true,
					"is_cancelled":false,
					"is_hidden":false,
					"was_forced":false,
					"original_amount":"0.01",
					"remaining_amount":"0.01",
					"executed_amount":"0.0"
				},{
					"id":448383729,
					"symbol":"btcusd",
					"exchange":"bitfinex",
					"price":"0.03",
					"avg_execution_price":"0.0",
					"side":"buy",
					"type":"exchange limit",
					"timestamp":"1444274013.661297306",
					"is_live":true,
					"is_cancelled":false,
					"is_hidden":false,
					"was_forced":false,
					"original_amount":"0.02",
					"remaining_amount":"0.02",
					"executed_amount":"0.0"
				}],
				"status":"success"
			}
		}	

		let(:orders){	[{symbol: "btcusd", amount: 0.01, price: 0.01, side: "buy"},
									 {symbol: "btcusd", amount: 0.01, price: 0.01, side: "buy"}] }
		before do
			stub_http("/order/new/multi", multiple_orders.to_json, method: :post)
			@orders = client.multiple_orders(orders: orders)
		end

		it {expect(@orders["status"]).to eq("success")}
		it {expect(@orders["order_ids"].size).to eq(2)}

	end
end
