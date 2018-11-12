require_relative './model'

module Bitfinex
  module Models
    class FundingTrade < Model
      BOOL_FIELDS = []
      FIELDS = {
        :id => 0,
        :symbol => 1,
        :mts_create => 2,
        :offer_id => 3,
        :amount => 4,
        :rate => 5,
        :period => 6,
        :maker => 7
      }

      FIELDS.each do |key, index|
        attr_accessor key
      end

      def initialize (data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      def self.unserialize (data)
        return Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
