# Bitfinex Trading API for Ruby. Bitcoin, Ether and Litecoin trading

[![Code Climate](https://codeclimate.com/repos/56db27e5b86182573b0045ed/badges/bd763083d70114379a41/gpa.svg)](https://codeclimate.com/repos/56db27e5b86182573b0045ed/feed)

* Official implementation
* REST API
* WebSockets API 
* REST API version 2
* WebSockets API version 2


## Installation

Add this line to your application's Gemfile:

    gem 'bitfinex-rb', :require => "bitfinex"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitfinex-rb

This repo is primarily made up of 3 classes: RESTv1, RESTv2, and WSv2, which implement their respective versions of the Bitfinex API. It is recommended that you use the REST APIs for reading data, and the WebSocket API for submitting orders and interacting with the Bitfinex platform.

## Usage of RESTv1/RESTv2

To use the REST APIs, construct a new API client with your account credentials:

```ruby
client = Bitfinex::RESTv2.new({
  :api_key => '...',
  :api_secret => '...',
})
```

Then use it to submit queries, i.e. `client.balances`

## Usage of WSv2
To use version 2 of the WS API, construct a new client with your credentials, bind listeners to react to stream events, and open the connection:

```ruby
client = Bitfinex::WSv2.new({
  :url => ENV['WS_URL'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET'],
  :transform => true, # provide models as event data instead of arrays
  :seq_audit => true, # enable and audit sequence numbers
  :manage_order_books => true # allows for OB checksum verification
  :checksum_audit => true, # enables OB checksum verification (needs manage_order_books)
})

client.on(:open) do
  client.auth!
end

client.on(:auth) do
  puts 'succesfully authenticated'

  o = Bitfinex::Models::Order.new({
    :type => 'EXCHANGE LIMIT',
    :price => 3.0152235,
    :amount => 2.0235235263262,
    :symbol => 'tEOSUSD'
  })

  client.submit_order(o)
end

client.on(:notification) do |n|
  puts 'received notification: %s' % [n]
end

client.on(:order_new) do |msg|
  puts 'recv order new: %s' % [msg]
end

client.open!
```

### Order Manipulation
Three methods are provided for dealing with orders: `submit_order`, `update_order` and `cancel_order`. All methods support callback blocks, which are triggered upon receiving the relevant confirmation notifications. Example:

```ruby
o = Bitfinex::Models::Order.new({
  :type => 'EXCHANGE LIMIT',
  :price => 3.0152235,
  :amount => 2.0235235263262,
  :symbol => 'tEOSUSD'
})

client.submit_order(o) do |order_packet|
  p "recv order confirmation packet with ID #{order_packet.id}"

  client.update_order({
    :id => order_packet.id,
    :price => '3.0'
  }) do |update_packet|
    p "updated order #{update_packet.id} with price #{update_packet.price}"

    client.cancel_order(order_packet) do |canceled_order|
      p "canceled order with ID #{canceled_order[0]}"
    end
  end
end
```

### Available Events
#### Lifecycle Events
* `:open`
* `:close`
* `:error`
* `:auth:`

#### Info Events
* `:server_restart`
* `:server_maintenance_start`
* `:server_maintenance_end`
* `:unsubscribed`
* `:subscribed`

#### Data Events
* `:ticker`
* `:public_trades`
* `:public_trade_entry`
* `:public_trade_update`
* `:candles`
* `:checksum`
* `:order_book`
* `:notification`
* `:trade_entry`
* `:trade_update`
* `:order_snapshot`
* `:order_update`
* `:order_new`
* `:order_close`
* `:position_snapshot`
* `:position_new`
* `:position_update`
* `:position_close`
* `:funding_offer_snapshot`
* `:funding_offer_new`
* `:funding_offer_update`
* `:funding_offer_close`
* `:funding_credit_snapshot`
* `:funding_credit_new`
* `:funding_credit_update`
* `:funding_credit_close`
* `:funding_loan_snapshot`
* `:funding_loan_new`
* `:funding_loan_update`
* `:funding_loan_close`
* `:wallet_snapshot`
* `:wallet_update`
* `:balance_update`
* `:marign_info_update`
* `:funding_info_update`
* `:funding_trade_entry`
* `:funding_trade_update`

Check the [Bitfinex API documentation](http://docs.bitfinex.com/) for more information.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bitfinex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
