# frozen_String_literal: true

require 'bigdecimal'
require_relative './model'

module Bitfinex
  module Models
    # Order model
    class Order < Model # rubocop:disable Metrics/ClassLength
      BOOL_FIELDS = [].freeze # @private

      # Hash<->Array field index mapping
      FIELDS = {
        id: 0,
        gid: 1,
        cid: 2,
        symbol: 3,
        mts_create: 4,
        mts_update: 5,
        amount: 6,
        amount_orig: 7,
        type: 8,
        type_prev: 9,
        mts_tif: 10,
        # placeholder
        flags: 12,
        status: 13,
        # placeholder
        # placeholder
        price: 16,
        price_avg: 17,
        price_trailing: 18,
        price_aux_limit: 19,
        # placeholder
        # placeholder
        # placeholder
        notify: 23,
        hidden: 24,
        placed_id: 25,
        # placeholder
        # placeholder
        routing: 28,
        # placeholder
        # placeholder
        meta: 31
      }.freeze

      # @return [Numeric]
      attr_accessor :id

      # @return [Numeric]
      attr_accessor :gid

      # @return [Numeric]
      attr_accessor :cid

      # @return [String]
      attr_accessor :symbol

      # @return [Numeric]
      attr_accessor :mts_create

      # @return [Numeric]
      attr_accessor :mts_update

      # @return [Numeric]
      attr_accessor :amount

      # @return [Numeric]
      attr_accessor :amount_orig

      # @return [String]
      attr_accessor :type

      # @return [String]
      attr_accessor :type_prev

      # @return [Numeric]
      attr_accessor :mts_tif

      # @return [Numeric]
      attr_accessor :flags

      # @return [String]
      attr_accessor :status

      # @return [Numeric]
      attr_accessor :price

      # @return [Numeric]
      attr_accessor :price_avg

      # @return [Numeric]
      attr_accessor :price_trailing

      # @return [Numeric]
      attr_accessor :price_aux_limit

      # @return [Boolean]
      attr_accessor :notify

      # @return [Boolean]
      attr_accessor :hidden

      # @return [Numeric]
      attr_accessor :placed_id

      # @return [String]
      attr_accessor :routing

      # @return [Hash, nil]
      attr_accessor :meta

      # @return [Numeric]
      attr_accessor :last_amount

      # @return [Numeric]
      attr_accessor :lev

      # Order-cancels-order flag, use with modify_flag (16384)
      FLAG_OCO = 2**14

      # Post-only flag, use with modify_flag (4096)
      FLAG_POSTONLY = 2**12

      # Hidden flag, use with modify_flag (64)
      FLAG_HIDDEN = 2**6

      # No-variable-rates flag, use with modify-flag (524288)
      FLAG_NO_VR = 2**19

      # Position-close flag, use with modify-flag (512)
      FLAG_POS_CLOSE = 2**9

      # Reduce-only flag, use with modify-flag (1024)
      FLAG_REDUCE_ONLY = 2**10

      # @private
      @@last_cid = Time.now.to_i # rubocop:disable all

      # @return [Numeric]
      # @private
      def self.gen_cid
        @@last_cid += 1 # rubocop:disable Style/ClassVars
        @@last_cid
      end

      # @param data [Hash]
      # @option data [Numeric] :id
      # @option data [Numeric] :gid
      # @option data [Numeric] :cid
      # @option data [String] :symbol
      # @option data [Numeric] :mts_create
      # @option data [Numeric] :mts_update
      # @option data [Numeric] :amount
      # @option data [Numeric] :amount_orig
      # @option data [String] :type
      # @option data [String] :type_prev
      # @option data [Numeric] :mts_tif
      # @option data [Numeric] :flags
      # @option data [String] :status
      # @option data [Numeric] :price
      # @option data [Numeric] :price_avg
      # @option data [Numeric] :price_trailing
      # @option data [Numeric] :price_aux_limit
      # @option data [Boolean] :notify
      # @option data [Boolean] :hidden
      # @option data [Boolean] :placed_id
      # @option data [String] :routing
      # @option data [Hash] :meta
      def initialize(data) # rubocop:disable all
        super(data, FIELDS, BOOL_FIELDS)

        @flags = 0 unless @flags.is_a?(Numeric)
        @amount_orig = @amount if @amount_orig.nil? && !@amount.nil?
        @last_amount = @amount

        return unless data.is_a?(Hash)

        set_oco(data[:oco]) if data.key?(:oco)
        set_hidden(data[:hidden]) if data.key?(:hidden)
        set_post_only(data[:post_only]) if data.key?(:post_only)
        @lev = data[:lev] if data.key?(:lev)
      end

      # Convert an array-format order to a Hash
      #
      # @param data [Array]
      # @return [Hash]
      def self.unserialize(data)
        Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end

      # Set or unset a flag, see FLAG_* class constants
      #
      # @param flag [Numeric]
      # @param active [Boolean] set or unset
      # @return [Numeric] new flags value
      def modify_flag(flag, active)
        return if (@flags & flag != 0) == active

        @flags += active ? flag : -flag
        @flags
      end

      # Set or unset the order-cancels-order flag
      #
      # @param value [Boolean] set or unset
      # @param stop_price [Numeric] defaults to current value
      # @return [Numeric] new flags value
      def set_oco(value, stop_price = @price_aux_limit)
        @price_aux_limit = stop_price if value

        modify_flag(FLAG_OCO, value)
        v
      end

      # Set or unset the hidden flag
      #
      # @param value [Boolean] set or unset
      # @return [Numeric] new flags value
      def set_hidden(value) # rubocop:disable Naming/AccessorMethodName
        modify_flag(FLAG_HIDDEN, value)
      end

      # Set or unset the post-only flag
      #
      # @param value [Boolean] set or unset
      # @return [Numeric] new flags value
      def set_post_only(value) # rubocop:disable Naming/AccessorMethodName
        modify_flag(FLAG_POSTONLY, value)
      end

      # Set or unset the no-variable-rates flag
      #
      # @param value [Boolean] set or unset
      # @return [Numeric] new flags value
      def set_no_variable_rates(value) # rubocop:disable Naming/AccessorMethodName
        modify_flag(FLAG_NO_VR, value)
      end

      # Set or unset the position-close flag
      #
      # @param value [Boolean] set or unset
      # @return [Numeric] new flags value
      def set_position_close(value) # rubocop:disable Naming/AccessorMethodName
        modify_flag(FLAG_POS_CLOSE, value)
      end

      # Set or unset the reduce-only flag
      #
      # @param value [Boolean] set or unset
      # @return [Numeric] new flags value
      def set_reduce_only(value) # rubocop:disable Naming/AccessorMethodName
        modify_flag(FLAG_REDUCE_ONLY, value)
      end

      # @return [Boolean]
      def is_oco # rubocop:disable Naming/PredicateName
        !(@flags & FLAG_OCO).nil?
      end

      # @return [Boolean]
      def is_hidden # rubocop:disable Naming/PredicateName
        !(@flags & FLAG_HIDDEN).nil?
      end

      # @return [Boolean]
      def is_post_only # rubocop:disable Naming/PredicateName
        !(@flags & FLAG_POSTONLY).nil?
      end

      # @return [Boolean]
      def includes_variable_rates
        !(@flags & FLAG_NO_VR).nil?
      end

      # @return [Boolean]
      def is_position_close # rubocop:disable Naming/PredicateName
        !(@flags & FLAG_POS_CLOSE).nil?
      end

      # @return [Boolean]
      def is_reduce_only # rubocop:disable Naming/PredicateName
        !(@flags & FLAG_REDUCE_ONLY).nil?
      end

      # @return [Boolean]
      def get_last_fill_amount # rubocop:disable Naming/AccessorMethodName
        @last_amount - @amount
      end

      # @return [Boolean]
      def reset_fill_amount
        @last_amount = @amount
      end

      # @return [Boolean]
      def get_base_currency # rubocop:disable Naming/AccessorMethodName
        @symbol[1...4]
      end

      # @return [Boolean]
      def get_quote_currency # rubocop:disable Naming/AccessorMethodName
        @symbol[4..-1]
      end

      # @return [Boolean]
      def get_notional_value # rubocop:disable Naming/AccessorMethodName
        (@amount * @price).abs
      end

      # @return [Boolean]
      def is_partially_filled # rubocop:disable Naming/PredicateName
        a = @amount.abs
        a.positive? && a < @amount_orig.abs
      end

      # Generates a new Hash that can be passed to the Bitfinex API to create
      # a new order matching this one
      #
      # @return [Hash]
      def to_new_order_packet # rubocop:disable all
        cid = if !@cid.nil?
                @cid
              else
                Order.gen_cid
              end

        data = {
          cid: cid,
          symbol: @symbol,
          type: @type,
          amount: BigDecimal(@amount, 8).to_s,
          flags: @flags || 0,
          meta: @meta
        }
        data[:gid] = @gid unless @gid.nil?
        data[:lev] = @lev unless @lev.nil?

        data[:price] = BigDecimal(@price, 5).to_s unless @price.nil?
        unless @price_trailing.nil?
          data[:price_trailing] = BigDecimal(@price_trailing, 5).to_s
        end

        unless @price_aux_limit.nil?
          if is_oco
            data[:price_oco_stop] = BigDecimal(@price_aux_limit, 5).to_s
          else
            data[:price_aux_limit] = BigDecimal(@price_aux_limit, 5).to_s
          end
        end

        data
      end

      # Updates the instance with an update packet from the API
      #
      # @param changes [Hash]
      # @return [nil]
      def update(changes = {}) # rubocop:disable all
        changes.each do |k, v|
          break if k == 'id'

          if FIELDS.key?(k)
            instance_variable_set(k, v)
          elsif k == 'price_trailing'
            @price_trailing = v.to_f
          elsif %w[price_oco_stop price_aux_limit].include?(k)
            @price_aux_limit = v.to_f
          elsif k == 'delta' && v.is_a?(Numeric) && @amount.is_a?(Numeric)
            @amount += v.to_f
            @last_amount = @amount
          end
        end
      end
    end
  end
end
