module Bitfinex
  module Models
    class Model
      def initialize (data, fields, boolFields)
        @fields = fields
        @boolFields = boolFields

        if data.kind_of?(Array)
          apply(self.class.unserialize(data))
        elsif data.kind_of?(Hash)
          apply(data)
        end
      end

      def serialize
        arr = []

        @fields.each do |key, index|
          return if index.nil?

          if @boolFields.include?(key)
            arr[index] = instance_variable_get("@#{key}") ? 1 : 0
          else
            arr[index] = instance_variable_get("@#{key}")
          end
        end

        arr
      end

      def apply (obj)
        @fields.each do |key, index|
          return if index.nil?

          instance_variable_set("@#{key}", obj[key])
        end
      end

      def self.unserialize (data, fields, boolFields)
        obj = {}

        fields.each do |key, index|
          return if index.nil?

          if boolFields.include?(key)
            obj[key] = data[index] == 1
          else
            obj[key] = data[index]
          end
        end

        return obj
      end
    end
  end
end