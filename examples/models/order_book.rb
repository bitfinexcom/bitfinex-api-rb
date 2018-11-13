require_relative '../../lib/bitfinex'
require_relative '../../lib/models/order_book'

ob_object = Bitfinex::Models::OrderBook.unserialize([
  [140, 1, 10],
  [145, 1, 10],
  [148, 1, 10],
  [149, 1, 10],
  [151, 1, -10],
  [152, 1, -10],
  [158, 1, -10],
  [160, 1, -10]
])

p ob_object

ob = Bitfinex::Models::OrderBook.new(ob_object)

puts ob.checksum

ob_array = ob.serialize()

puts ob_array