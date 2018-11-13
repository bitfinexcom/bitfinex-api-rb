require_relative './model'

module Bitfinex
  module Models
    class Movement < Model
      BOOL_FIELDS = []
      FIELDS = {
        :id => 0,
        :currency => 1,
        :currency_name => 2,
        :mts_started => 5,
        :mts_updated => 6,
        :status => 9,
        :amount => 12,
        :fees => 13,
        :destination_address => 16,
        :transaction_id => 20
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
