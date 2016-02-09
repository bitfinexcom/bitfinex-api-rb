module Bitfinex
  class JSONParser < HTTParty::Parser
    SupportedFormats.merge!({ 'application/json' => :to_json})

    def to_json
      JSON.parse body
    end
  end
end
