require_relative '../../../lib/bitfinex.rb'

client = Bitfinex::RESTv2.new({
  :url => ENV['REST_URL'],
  :api_key => ENV['API_KEY'],
  :api_secret => ENV['API_SECRET']
})

# Get pulse profile
p client.get_pulse_profile('Bitfinex')

# Get public pulse history
p client.get_public_pulse_history({ :limit => 5 })

# Submit new Pulse message
pulse = client.submit_pulse({
  :title =>    '1234 5678 Foo Bar Baz Qux TITLE',
  :content =>  '1234 5678 Foo Bar Baz Qux Content',
  :isPublic => 0,
  :isPin =>    1
})
p pulse

# Delete Pulse message
p "About to delete pulse: #{pulse[:id]}"
p client.delete_pulse(pulse[:id])

# Get private pulse history
p client.get_private_pulse_history()

# Submit Pulse message comment
# 1 - create pulse message
pulse2 = client.submit_pulse({
  :title =>    '2 1234 5678 Foo Bar Baz Qux TITLE',
  :content =>  '2 1234 5678 Foo Bar Baz Qux Content',
  :isPublic => 0,
  :isPin =>    1
})

# 2 - submit comment for above pulse message
p client.submit_pulse_comment({
  :parent => pulse2[:id],
  :title =>    'comment 2 1234 5678 Foo Bar Baz Qux TITLE',
  :content =>  'comment 2 1234 5678 Foo Bar Baz Qux Content',
  :isPublic => 0,
  :isPin =>    1
})
