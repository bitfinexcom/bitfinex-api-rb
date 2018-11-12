require_relative './model'

module Bitfinex
  module Models
    class LedgerEntry < Model
      BOOL_FIELDS = []
      FIELDS = {
        :id => 0,
        :currency => 1,
        :mts => 3,
        :amount => 5,
        :balance => 6,
        :description => 8,
        :wallet => nil
      }

      FIELDS.each do |key, index|
        attr_accessor key
      end

      def initialize (data)
        super(data, FIELDS, BOOL_FIELDS)

        spl = self.description.split('wallet')
        self.wallet = (spl && spl[1]) ? spl[1].trim() : nil
      end

      def self.unserialize (data)
        return Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
