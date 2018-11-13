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
  :api_secret => ENV['API_SECRET']
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

Check the [Bitfinex API documentation](http://docs.bitfinex.com/) for more information.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bitfinex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
