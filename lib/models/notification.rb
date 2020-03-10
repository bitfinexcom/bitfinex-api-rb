# frozen_string_literal: true

require_relative './model'

module Bitfinex
  module Models
    # Notification model
    class Notification < Model
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        mts: 0,
        type: 1,
        message_id: 2,
        notify_info: 4,
        code: 5,
        status: 6,
        text: 7
      }.freeze

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      # @param data [Hash]
      # @option data [Number] :mts
      # @option data [String] :type
      # @option data [Number] :message_id
      # @option data [Hash, nil] :notify_info
      # @option data [Number] :code
      # @option data [String] :status
      # @option data [String] :text
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)
      end

      # Convert an array-format notification to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end
    end
  end
end
