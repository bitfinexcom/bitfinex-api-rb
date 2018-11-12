require_relative './model'

module Bitfinex
  module Models
    class Notification < Model
      BOOL_FIELDS = []
      FIELDS = {
        :mts => 0,
        :type => 1,
        :message_id => 2,
        :notify_info => 4,
        :code => 5,
        :status => 6,
        :text => 7
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
