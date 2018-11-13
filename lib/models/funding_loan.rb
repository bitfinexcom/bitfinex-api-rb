require_relative './model'

module Bitfinex
  module Models
    class FundingLoan < Model
      BOOL_FIELDS = ['notify', 'hidden', 'renew', 'no_close']
      FIELDS = {
        :id => 0,
        :symbol => 1,
        :side => 2,
        :mts_create => 3,
        :mts_update => 4,
        :amount => 5,
        :flags => 6,
        :status => 7,
        :rate => 11,
        :period => 12,
        :mts_opening => 13,
        :mts_last_payout => 14,
        :notify => 15,
        :hidden => 16,
        :renew => 18,
        :rate_real => 19,
        :no_close => 20
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
