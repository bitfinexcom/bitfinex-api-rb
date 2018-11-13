require_relative '../../lib/bitfinex'
require_relative '../../lib/models/funding_offer'

fo_object = Bitfinex::Models::FundingOffer.unserialize([
  123, 'tBTCUSD', Time.now.to_i, Time.now.to_i, 1, 1, 'LIMIT', nil, nil, 0,
  'ACTIVE', nil, nil, nil, 0.012, 4, 0, 0, nil, 0, 0.012
])

p fo_object

fo_model = Bitfinex::Models::FundingOffer.new(fo_object)

p fo_model

fo_array = fo_model.serialize()

p fo_array