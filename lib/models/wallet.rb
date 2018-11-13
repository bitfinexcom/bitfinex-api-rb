require_relative './model'

module Bitfinex
  module Models
    class Wallet < Model
      BOOL_FIELDS = []
      FIELDS = {
        :type => 0,
        :currency => 1,
        :balance => 2,
        :unsettled_interest => 3,
        :balance_available => 4
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
