module Bitfinexrb
  #
  class Orders < Authenticated
    def all
      uri = "/#{@api_version}/orders"
      self.class.post(uri, headers: headers_for(uri)).parsed_response
    end

    def cancel_all
      uri = "/#{@api_version}/order/cancel/all"
      self.class.get(uri, headers: headers_for(uri)).parsed_response
    end

    def create(pair, amount, order_type, price = nil, options = {})
      uri = "/#{@api_version}/order/new"
      opts = {
        is_hidden: false
      }.merge(options)
      if amount < 0.000000000
        opts[:amount] = amount.abs.to_s
        opts[:side] = 'sell'
      else
        opts[:amount] = amount.to_s
        opts[:side] = 'buy'
      end

      price = '9999999' if order_type.include?('market') && opts[:side] == 'sell'
      price = '10' if order_type.include?('market') && opts[:side] == 'buy'

      order = {
        'symbol' => pair,
        'price' => price,
        'amount' => opts[:amount],
        'exchange' => 'bitfinex',
        'side' => opts[:side],
        'type' => order_type
      }

      begin
        res = self.class.post(uri, headers: headers_for(uri, order))
        unless res.response.code == '200'
          puts "Server returned #{res.response.code}"
          msg = res.parsed_response['message'] || 'no response'
          fail msg
        end
      rescue => e
        puts "Error creating order #{e}"
      end
    end
  end
end
