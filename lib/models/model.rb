# frozen_string_literal: true

module Bitfinex
  module Models
    # Base model class, allows for mapping indexes into an array-format Bitfinex
    # API model to named keys on a Hash
    class Model
      # Model constructor, accepts field definitions
      #
      # @param data [Hash, Array] can also be an array
      # @param fields [Hash] mapping of keys (field names) to array indexes
      # @param boolFields [Array<Symbol>] array of field names to be treated
      #   as booleans
      def initialize(data, fields, boolFields)
        @fields = fields
        @boolFields = boolFields

        if data.is_a?(Array)
          apply(self.class.unserialize(data))
        elsif data.is_a?(Hash)
          apply(data)
        end
      end

      # Returns a Bitfinex API array-format representation of the model
      # instance
      #
      # @return [Array]
      def serialize
        arr = []

        @fields.each do |key, index|
          return if index.nil?

          arr[index] = if @boolFields.include?(key)
                         instance_variable_get("@#{key}") ? 1 : 0
                       else
                         instance_variable_get("@#{key}")
                       end
        end

        arr
      end

      # Sets field values from a Hash
      #
      # @param data [Hash]
      def apply(data)
        @fields.each do |key, index|
          return if index.nil?

          instance_variable_set("@#{key}", data[key])
        end
      end

      # High level method that generates a Hash-format model instance from an
      # Array and a set of field mappings. Should only be used by model classes
      #
      # @param data [Array]
      # @param fields [Hash] mapping of keys (field names) to array indexes
      # @param boolFields [Array<Symbol>] array of field names to be treated
      #   as booleans
      # @return [Hash]
      def self.unserialize(data, fields, boolFields)
        obj = {}

        fields.each do |key, index|
          return if index.nil?

          obj[key] = if boolFields.include?(key)
                       data[index] == 1
                     else
                       data[index]
                     end
        end

        obj
      end
    end
  end
end
