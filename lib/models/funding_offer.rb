require_relative './model'

module Bitfinex
  module Models
    class FundingOffer < Model
      BOOL_FIELDS = ['notify', 'hidden', 'renew']
      FIELDS = {
        :id => 0,
        :symbol => 1,
        :mts_create => 2,
        :mts_update => 3,
        :amount => 4,
        :amount_orig => 5,
        :type => 6,
        :flags => 9,
        :status => 10,
        :rate => 14,
        :period => 15,
        :notify => 16,
        :hidden => 17,
        :renew => 19,
        :rate_real => 20
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
