# frozen_string_literal: true

require 'zlib'

module Bitfinex
  module Models
    # Order Book model
    class OrderBook
      attr_reader :raw, :bids, :asks

      # @param snap [Array<Array>, Hash, OrderBook] book snapshot
      # @param raw [Boolean]
      def initialize(snap = [], raw = false)
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
      def update_from_snapshot(snap = [])
        @bids = []
        @asks = []

        snap = [snap] unless snap[0].is_a?(Array)

        snap.each do |entry|
          if entry.size == 4
            if entry[3] < 0
              @bids.push(entry)
            else
              @asks.push(entry)
            end
          else
            if entry[2] < 0
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
      # @return [Number]
      def top_bid
        priceI = if raw
                   @bids[0].size == 4 || @asks[0].size == 4 ? 2 : 1
                 else
                   0
                 end

        (top_bid_level || [])[priceI] || nil
      end

      # Fetch the best ask level
      #
      # @return [Array]
      def top_ask_level
        @asks[0] || nil
      end

      # Fetch the best ask price
      #
      # @return [Number]
      def top_ask
        priceI = if raw
                   @bids[0].size == 4 || @asks[0].size == 4 ? 2 : 1
                 else
                   0
                 end

        (top_ask_level || [])[priceI] || nil
      end

      # Fetch the order book mid price (halfway between top bid and top ask)
      #
      # @return [Number]
      def mid_price
        ask = top_ask || 0
        bid = top_bid || 0

        return bid if ask == 0
        return ask if bid == 0

        (bid + ask) / 2
      end

      # Fetch the spread between the top bid and top ask
      #
      # @return [Number]
      def spread
        ask = top_ask || 0
        bid = top_bid || 0

        return 0 if ask == 0 || bid == 0

        ask - bid
      end

      # Fetch the total bid amount
      #
      # @return [Number]
      def bid_amount
        amount = 0

        @bids.each do |entry|
          amount += entry.size == 4 ? entry[3] : entry[2]
        end

        amount.abs
      end

      # Fetch the total ask amount
      #
      # @return [Number]
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
      # @return [Number]
      def checksum
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
      def update_with(entry)
        if @raw
          priceI = entry.size == 4 ? 2 : 1
          count = -1
        else
          priceI = 0
          count = entry.size == 4 ? entry[2] : entry[1]
        end

        price = entry[priceI]
        oID = entry[0] # only for raw books
        amount = entry.size == 4 ? entry[3] : entry[2]

        if entry.size == 4
          dir = amount < 0 ? 1 : -1
          side = amount < 0 ? @bids : @asks
        else
          dir = amount < 0 ? -1 : 1
          side = amount < 0 ? @asks : @bids
        end

        insertIndex = -1

        # apply insert directly if empty
        if side.empty? && (@raw || count > 0)
          side.push(entry)
          return true
        end

        # match by price level, or order ID for raw books
        side.each_with_index do |pl, i|
          if (!@raw && pl[priceI] == price) || (@raw && pl[0] == oID)
            if (!@raw && count == 0) || (@raw && price == 0)
              side.slice!(i, 1)
              return true
            elsif !@raw || (@raw && price > 0)
              side.slice!(i, 1)
              break
            end
          end
        end

        return false if (@raw && price == 0) || (!@raw && count == 0)

        side.each_with_index do |pl, i|
          next unless insertIndex == -1 && (
            (dir == -1 && price < pl[priceI]) || # by price
            (dir == -1 && price == pl[priceI] && (raw && entry[0] < pl[0])) || # by order ID
            (dir == 1 && price > pl[priceI]) ||
            (dir == 1 && price == pl[priceI] && (raw && entry[0] < pl[0]))
          )

          insertIndex = i
          break
        end

        # add
        if insertIndex == -1
          side.push(entry)
        else
          side.insert(insertIndex, entry)
        end

        true
      end

      # Convert an array-format (snapshot) order book to a Hash
      #
      # @param arr [Array]
      # @param raw [Boolean]
      def self.unserialize(arr, raw = false)
        if arr[0].is_a?(Array)
          entries = arr.map { |e| OrderBook.unserialize(e, raw) }
          bids = entries.select { |e| (e[:rate] ? -e[:amount] : e[:amount]) > 0 }
          asks = entries.select { |e| (e[:rate] ? -e[:amount] : e[:amount]) < 0 }

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
          if raw
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
