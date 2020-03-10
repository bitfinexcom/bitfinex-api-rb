# frozen_string_literal: true

require 'zlib'

module Bitfinex
  module Models
    # Order Book model
    class OrderBook # rubocop:disable Metrics/ClassLength
      # @return [Boolean]
      attr_reader :raw

      # @return [Array]
      attr_reader :bids

      # @return [Array]
      attr_reader :asks

      # @param snap [Array<Array>, Hash, OrderBook] book snapshot
      # @param raw [Boolean]
      def initialize(snap = [], raw = false) # rubocop:disable Metrics/MethodLength
        @raw = raw

        if snap.instance_of?(OrderBook)
          @bids = snap.bids.dup
          @asks = snap.asks.dup
        elsif snap.is_a?(Array)
          update_from_snapshot(snap)
        elsif snap.is_a?(Hash)
          @bids = snap[:bids].dup
          @asks = snap[:asks].dup
        else
          @bids = []
          @asks = []
        end
      end

      # Resets and updates the instance from the provided order book snapshot
      #
      # @param snap [Array] book snapshot
      # @return [nil]
      def update_from_snapshot(snap = []) # rubocop:disable all
        @bids = []
        @asks = []

        snap = [snap] unless snap[0].is_a?(Array)

        snap.each do |entry|
          if entry.size == 4
            if entry[3].negative?
              @bids.push(entry)
            else
              @asks.push(entry)
            end
          else
            if entry[2].negative? # rubocop:disable Style/IfInsideElse
              @asks.push(entry)
            else
              @bids.push(entry)
            end
          end
        end

        price_i = if raw
                    snap[0].size == 4 ? 2 : 1
                  else
                    0
                  end

        @bids.sort! { |a, b| b[price_i] <=> a[price_i] }
        @asks.sort! { |a, b| a[price_i] <=> b[price_i] }
      end

      # Fetch the best bid level
      #
      # @return [Array]
      def top_bid_level
        @bids[0] || nil
      end

      # Fetch the best bid price
      #
      # @return [Numeric]
      def top_bid
        price_i = if raw
                    @bids[0].size == 4 || @asks[0].size == 4 ? 2 : 1
                  else
                    0
                  end

        (top_bid_level || [])[price_i] || nil
      end

      # Fetch the best ask level
      #
      # @return [Array]
      def top_ask_level
        @asks[0] || nil
      end

      # Fetch the best ask price
      #
      # @return [Numeric]
      def top_ask
        price_i = if raw
                    @bids[0].size == 4 || @asks[0].size == 4 ? 2 : 1
                  else
                    0
                  end

        (top_ask_level || [])[price_i] || nil
      end

      # Fetch the order book mid price (halfway between top bid and top ask)
      #
      # @return [Numeric]
      def mid_price
        ask = top_ask || 0
        bid = top_bid || 0

        return bid if ask.zero?
        return ask if bid.zero?

        (bid + ask) / 2
      end

      # Fetch the spread between the top bid and top ask
      #
      # @return [Numeric]
      def spread
        ask = top_ask || 0
        bid = top_bid || 0

        return 0 if ask.zero? || bid.zero?

        ask - bid
      end

      # Fetch the total bid amount
      #
      # @return [Numeric]
      def bid_amount
        amount = 0

        @bids.each do |entry|
          amount += entry.size == 4 ? entry[3] : entry[2]
        end

        amount.abs
      end

      # Fetch the total ask amount
      #
      # @return [Numeric]
      def ask_amount
        amount = 0

        @asks.each do |entry|
          amount += entry.size == 4 ? entry[3] : entry[2]
        end

        amount.abs
      end

      # Returns an array (snapshot) representation of this instance
      #
      # @return [Array]
      def serialize
        @asks + @bids
      end

      # Generate a checksum of this instance, which can be compared with API
      # checksums for integrity validation
      #
      # @return [Numeric]
      def checksum # rubocop:disable all
        data = []

        (0...25).each do |i|
          bid = @bids[i]
          ask = @asks[i]

          unless bid.nil?
            price = bid[0]
            data.push(price)
            data.push(bid.size == 4 ? bid[3] : bid[2])
          end

          next if ask.nil?

          price = ask[0]
          data.push(price)
          data.push(ask.size == 4 ? ask[3] : ask[2])
        end

        [Zlib.crc32(data.join(':'))].pack('I').unpack('i')[0]
      end

      # Update the order book with a price level
      #
      # @param entry [Array]
      # @return [nil]
      def update_with(entry) # rubocop:disable all
        if @raw
          price_i = entry.size == 4 ? 2 : 1
          count = -1
        else
          price_i = 0
          count = entry.size == 4 ? entry[2] : entry[1]
        end

        price = entry[price_i]
        o_id = entry[0] # only for raw books
        amount = entry.size == 4 ? entry[3] : entry[2]

        if entry.size == 4
          dir = amount.negative? ? 1 : -1
          side = amount.negative? ? @bids : @asks
        else
          dir = amount.negative? ? -1 : 1
          side = amount.negative? ? @asks : @bids
        end

        insert_i = -1

        # apply insert directly if empty
        if side.empty? && (@raw || count.positive?)
          side.push(entry)
          return true
        end

        # match by price level, or order ID for raw books
        side.each_with_index do |pl, i|
          if (!@raw && pl[price_i] == price) || (@raw && pl[0] == o_id)
            if (!@raw && count.zero?) || (@raw && price.zero?)
              side.slice!(i, 1)
              return true
            elsif !@raw || (@raw && price.positive?)
              side.slice!(i, 1)
              break
            end
          end
        end

        return false if (@raw && price.zero?) || (!@raw && count.zero?)

        side.each_with_index do |pl, i|
          next unless insert_i == -1 && (
            (dir == -1 && price < pl[price_i]) || # by price
            (dir == -1 && price == pl[price_i] && (raw && entry[0] < pl[0])) ||
            (dir == 1 && price > pl[price_i]) ||
            (dir == 1 && price == pl[price_i] && (raw && entry[0] < pl[0]))
          )

          insert_i = i
          break
        end

        # add
        if insert_i == -1
          side.push(entry)
        else
          side.insert(insert_i, entry)
        end

        true
      end

      # Convert an array-format (snapshot) order book to a Hash
      #
      # @param arr [Array]
      # @param raw [Boolean]
      # @return [Hash]
      def self.unserialize(arr, raw = false) # rubocop:disable all
        if arr[0].is_a?(Array)
          entries = arr.map { |e| OrderBook.unserialize(e, raw) }

          bids = entries.select do |e|
            (e[:rate] ? -e[:amount] : e[:amount]).positive?
          end

          asks = entries.select do |e|
            (e[:rate] ? -e[:amount] : e[:amount]).negative?
          end

          return {
            bids: bids,
            asks: asks
          }
        end

        if arr.size == 4
          if raw
            {
              order_id: arr[0],
              period: arr[1],
              rate: arr[2],
              amount: arr[3]
            }
          else
            {
              rate: arr[0],
              period: arr[1],
              count: arr[2],
              amount: arr[3]
            }
          end
        else
          if raw # rubocop:disable Style/IfInsideElse
            {
              order_id: arr[0],
              price: arr[1],
              amount: arr[2]
            }
          else
            {
              price: arr[0],
              count: arr[1],
              amount: arr[2]
            }
          end
        end
      end
    end
  end
end
