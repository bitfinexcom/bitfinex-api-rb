# frozen_string_literal: true

require 'bigdecimal'
require_relative './model'

module Bitfinex
  module Models
    # Order model
    class Order < Model
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
      @@last_cid = Time.now.to_i

      FIELDS.each do |key, _index|
        attr_accessor key
      end

      attr_accessor :last_amount, :lev

      # @private
      def self.gen_cid
        @@last_cid += 1
        @@last_cid
      end

      # @param data [Hash]
      # @option data [Number] :id
      # @option data [Number] :gid
      # @option data [Number] :cid
      # @option data [String] :symbol
      # @option data [Number] :mts_create
      # @option data [Number] :mts_update
      # @option data [Number] :amount
      # @option data [Number] :amount_orig
      # @option data [String] :type
      # @option data [String] :type_prev
      # @option data [Number] :mts_tif
      # @option data [Number] :flags
      # @option data [String] :status
      # @option data [Number] :price
      # @option data [Number] :price_avg
      # @option data [Number] :price_trailing
      # @option data [Number] :price_aux_limit
      # @option data [Boolean] :notify
      # @option data [Boolean] :hidden
      # @option data [Boolean] :placed_id
      # @option data [String] :routing
      # @option data [Hash] :meta
      def initialize(data)
        super(data, FIELDS, BOOL_FIELDS)

        @flags = 0 unless @flags.is_a?(Numeric)
        @amount_orig = @amount if @amount_orig.nil? && !@amount.nil?
        @last_amount = @amount

        if data.is_a?(Hash)
          set_oco(data[:oco]) if data.key?(:oco)
          set_hidden(data[:hidden]) if data.key?(:hidden)
          set_post_only(data[:post_only]) if data.key?(:post_only)
          @lev = data[:lev] if data.key?(:lev)
        end
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
      # @param flag [Number]
      # @param active [Boolean] set or unset
      # @return [Number] new flags value
      def modify_flag(flag, active)
        return if (@flags & flag != 0) == active

        @flags += active ? flag : -flag
        @flags
      end

      # Set or unset the order-cancels-order flag
      #
      # @param v [Boolean] set or unset
      # @param stop_price [Number] defaults to current value
      # @return [Number] new flags value
      def set_oco(v, stop_price = @price_aux_limit)
        @price_aux_limit = stop_price if v

        modify_flag(FLAG_OCO, v)
        v
      end

      # Set or unset the hidden flag
      #
      # @param v [Boolean] set or unset
      # @return [Number] new flags value
      def set_hidden(v)
        modify_flag(FLAG_HIDDEN, v)
      end

      # Set or unset the post-only flag
      #
      # @param v [Boolean] set or unset
      # @return [Number] new flags value
      def set_post_only(v)
        modify_flag(FLAG_POSTONLY, v)
      end

      # Set or unset the no-variable-rates flag
      #
      # @param v [Boolean] set or unset
      # @return [Number] new flags value
      def set_no_variable_rates(v)
        modify_flag(FLAG_NO_VR, v)
      end

      # Set or unset the position-close flag
      #
      # @param v [Boolean] set or unset
      # @return [Number] new flags value
      def set_position_close(v)
        modify_flag(FLAG_POS_CLOSE, v)
      end

      # Set or unset the reduce-only flag
      #
      # @param v [Boolean] set or unset
      # @return [Number] new flags value
      def set_reduce_only(v)
        modify_flag(FLAG_REDUCE_ONLY, v)
      end

      # @return [Boolean]
      def is_oco
        !!(@flags & FLAG_OCO)
      end

      # @return [Boolean]
      def is_hidden
        !!(@flags & FLAG_HIDDEN)
      end

      # @return [Boolean]
      def is_post_only
        !!(@flags & FLAG_POSTONLY)
      end

      # @return [Boolean]
      def includes_variable_rates
        !!(@flags & FLAG_NO_VR)
      end

      # @return [Boolean]
      def is_position_close
        !!(@flags & FLAG_POS_CLOSE)
      end

      # @return [Boolean]
      def is_reduce_only
        !!(@flags & FLAG_REDUCE_ONLY)
      end

      # @return [Boolean]
      def get_last_fill_amount
        @last_amount - @amount
      end

      # @return [Boolean]
      def reset_fill_amount
        @last_amount = @amount
      end

      # @return [Boolean]
      def get_base_currency
        @symbol[1...4]
      end

      # @return [Boolean]
      def get_quote_currency
        @symbol[4..-1]
      end

      # @return [Boolean]
      def get_notional_value
        (@amount * @price).abs
      end

      # @return [Boolean]
      def is_partially_filled
        a = @amount.abs
        a > 0 && a < @amount_orig.abs
      end

      # Generates a new Hash that can be passed to the Bitfinex API to create
      # a new order matching this one
      #
      # @return [Hash]
      def to_new_order_packet
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
      def update(changes = {})
        changes.each do |k, v|
          return if k == 'id'

          if FIELDS.key?(k)
            instance_variable_set(k, v)
          elsif k == 'price_trailing'
            @price_trailing = v.to_f
          elsif k == 'price_oco_stop' || k == 'price_aux_limit'
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
