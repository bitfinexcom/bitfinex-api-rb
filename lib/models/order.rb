require 'bigdecimal'
require_relative './model'

module Bitfinex
  module Models
    class Order < Model
      BOOL_FIELDS = []
      FIELDS = {
        :id => 0,
        :gid => 1,
        :cid => 2,
        :symbol => 3,
        :mts_create => 4,
        :mts_update => 5,
        :amount => 6,
        :amount_orig => 7,
        :type => 8,
        :type_prev => 9,
        :flags => 12,
        :status => 13,
        :price => 16,
        :price_avg => 17,
        :price_trailing => 18,
        :price_aux_limit => 19,
        :notify => 23,
        :placed_id => 25
      }

      FLAG_OCO = 2 ** 14         # 16384
      FLAG_POSTONLY = 2 ** 12    # 4096
      FLAG_HIDDEN = 2 ** 6       # 64
      FLAG_NO_VR = 2 ** 19       # 524288
      FLAG_POS_CLOSE = 2 ** 9    # 512
      FLAG_REDUCE_ONLY = 2 ** 10 # 1024

      @@last_cid = Time.now.to_i

      FIELDS.each do |key, index|
        attr_accessor key
      end

      attr_accessor :last_amount, :meta

      def self.gen_cid
        @@last_cid += 1
        @@last_cid
      end

      def initialize (data)
        super(data, FIELDS, BOOL_FIELDS)

        @flags = 0 unless @flags.is_a?(Numeric)
        @amount_orig = @amount if @amount_orig.nil? && !@amount.nil?
        @last_amount = @amount

        if data.kind_of?(Hash)
          set_oco(data[:oco]) if data.has_key?(:oco)
          set_hidden(data[:hidden]) if data.has_key?(:hidden)
          set_post_only(data[:post_only]) if data.has_key?(:post_only)
        end
      end

      def self.unserialize (data)
        return Model.unserialize(data, FIELDS, BOOL_FIELDS)
      end

      def modify_flag (flag, active)
        return if (@flags & flag != 0) == active

        @flags += active ? flag : -flag
      end

      def set_oco (v, stop_price = @price_aux_limit)
        @price_aux_limit = stop_price if v

        modify_flag(FLAG_OCO, v)
      end

      def set_hidden (v)
        modify_flag(FLAG_HIDDEN, v)
      end

      def set_post_only (v)
        modify_flag(FLAG_POSTONLY, v)
      end

      def set_no_variable_rates (v)
        modify_flag(FLAG_NO_VR, v)
      end

      def set_position_close (v)
        modify_flag(FLAG_POS_CLOSE, v)
      end

      def set_reduce_only (v)
        modify_flag(FLAG_REDUCE_ONLY, v)
      end

      def is_oco
        return !!(@flags & FLAG_OCO)
      end

      def is_hidden
        return !!(@flags & FLAG_HIDDEN)
      end

      def is_post_only
        return !!(@flags & FLAG_POSTONLY)
      end

      def includes_variable_rates
        return !!(@flags & FLAG_NO_VR)
      end

      def is_position_close
        return !!(@flags & FLAG_POS_CLOSE)
      end

      def is_reduce_only
        return !!(@flags & FLAG_REDUCE_ONLY)
      end

      def get_last_fill_amount
        @last_amount - @amount
      end

      def reset_fill_amount
        @last_amount = @amount
      end

      def get_base_currency
        @symbol[1...4]
      end

      def get_quote_currency
        @symbol[4..-1]
      end

      def get_notional_value
        (@amount * @price).abs
      end

      def is_partially_filled
        a = @amount.abs
        a > 0 && a < @amount_orig.abs
      end

      def to_new_order_packet
        if !@cid.nil?
          cid = @cid
        else
          cid = Order.gen_cid
        end

        data = {
          :gid => @gid,
          :cid => cid,
          :symbol => @symbol,
          :type => @type,
          :amount => BigDecimal.new(@amount, 8).to_s,
          :flags => @flags || 0,
          :meta => @meta
        }

        data[:price] = BigDecimal.new(@price, 5).to_s if !@price.nil?
        data[:price_trailing] = BigDecimal.new(@price_trailing, 5).to_s if !@price_trailing.nil?

        if !@price_aux_limit.nil?
          if is_oco
            data[:price_oco_stop] = BigDecimal.new(@price_aux_limit, 5).to_s
          else
            data[:price_aux_limit] = BigDecimal.new(@price_aux_limit, 5).to_s
          end
        end

        data
      end

      def update (changes = {})
        changes.each do |k, v|
          return if k == 'id'

          if FIELDS.has_key?(k)
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
