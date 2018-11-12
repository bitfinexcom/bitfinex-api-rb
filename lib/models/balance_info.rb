require_relative './model'

module Bitfinex
  module Models
    class BalanceInfo < Model
      BOOL_FIELDS = []
      FIELDS = {
        :amount => 0,
        :amount_net => 1
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
