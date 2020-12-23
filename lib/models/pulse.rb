require_relative './model'

module Bitfinex
  module Models
    class Pulse < Model
      BOOL_FIELDS = []
      FIELDS = {
        :id => 0,
        :mts_create => 1,
        :pulse_user_id => 3,
        :title => 5,
        :content => 6,
        :is_pin => 9,
        :is_public => 10,
        :comments_disabled => 11,
        :tags => 12,
        :attachments => 13,
        :meta => 14,
        :likes => 15,
        :profile => 18,
        :comments => 19
      }

      FIELDS.each do |key, index|
        attr_accessor key
      end

      def initialize (data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      def self.unserialize (data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
