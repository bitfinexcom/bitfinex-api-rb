require_relative './model'

module Bitfinex
  module Models
    class Alert < Model
      BOOL_FIELDS = []
      FIELDS = {
        :key => 0,
        :type => 1,
        :symbol => 2,
        :price => 3
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
