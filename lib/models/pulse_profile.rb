require_relative './model'

module Bitfinex
  module Models
    class PulseProfile < Model
      BOOL_FIELDS = []
      FIELDS = {
        :id => 0,
        :mts_create => 1,
        :nickname => 3,
        :picture => 5,
        :text => 6,
        :twitter_handle => 9,
        :followers => 11,
        :following => 12
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
