require 'zlib'

module Bitfinex
  module Models
    class OrderBook
      attr_reader :raw, :bids, :asks

      def initialize (snap = [], raw = false)
        @raw = raw

        if snap.instance_of?(OrderBook)
          @bids = snap.bids.dup
          @asks = snap.asks.dup
        elsif snap.kind_of?(Array)
          update_from_snapshot(snap)
        elsif snap.kind_of?(Hash)
          @bids = snap[:bids].dup
          @asks = snap[:asks].dup
        else
          @bids = []
          @asks = []
        end
      end

      def update_from_snapshot (snap = [])
        @bids = []
        @asks = []

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

        priceI = self.raw
          ? snap[0].size == 4 ? 2 : 1
          : 0

        @bids.sort! { |a, b| b[priceI] <=> a[priceI]}
        @asks.sort! { |a, b| a[priceI] <=> b[priceI]}
      end

      def top_bid_level
        @bids[0] || nil
      end

      def top_bid
        priceI = self.raw
          ? (@bids[0].size == 4 || @asks[0].size == 4) ? 2 : 1
          : 0
        
        (top_bid_level || [])[priceI] || nil
      end

      def top_ask_level
        @asks[0] || nil
      end

      def top_ask
         priceI = self.raw
          ? (@bids[0].size == 4 || @asks[0].size == 4) ? 2 : 1
          : 0
        
        (top_ask_level || [])[priceI] || nil
      end

      def mid_price
        ask = top_ask || 0
        bid = top_bid || 0

        return bid if ask == 0
        return ask if bid == 0

        return (bid + ask) / 2
      end

      def spread
        ask = top_ask || 0
        bid = top_bid || 0

        return 0 if ask == 0 || bid == 0

        return ask - bid
      end

      def bid_amount
        amount = 0

        @bids.each do |entry|
          amount += entry.size == 4 ? entry[3] : entry[2]
        end

        amount.abs
      end

      def ask_amount
        amount = 0

        @asks.each do |entry|
          amount += entry.size == 4 ? entry[3] : entry[2]
        end

        amount.abs
      end

      def serialize
        @asks + @bids
      end

      def checksum
        data = []

        for i in 0...25
          bid = @bids[i]
          ask = @asks[i]

          if !bid.nil?
            price = bid[0]
            data.push(price)
            data.push(bid.size == 4 ? bid[3] : bid[2])
          end

          if !ask.nil?
            price = ask[0]
            data.push(price)
            data.push(ask.size == 4 ? ask[3] : ask[2])
          end
        end

        Zlib::crc32(data.join(':'))
      end

      def update_width (entry)
        priceI = @raw
          ? entry.size == 4 ? 2 : 1
          : 0
        count = @raw
          ? -1
          : entry.size == 4 ? entry[2] : entry[1]
        price = entry[priceI]
        oID = entry[0] # only for raw books
        amount = entry.size == 4 ? entry[3] : entry[2]
        dir = entry.size == 4
          ? amount < 0 : 1 : -1
          : amount < 0 : -1 : 1
        side = entry.size == 4
          ? amount < 0 ? @bids : @asks
          ? amount < 0 ? @asks : @bids

        insertIndex = -1

        # apply insert directly if empty
        if (side.size == 0 && (@raw || count > 0))
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

        if (@raw && price == 0) || (!@raw && count == 0)
          return false
        end

        side.each_with_index do |pl, i|
          if (insertIndex == -1 && (
            (dir == -1 && price < pl[priceI]) || # by price
            (dir == -1 && price == pl[priceI] && (raw && entry[0] < pl[0])) || # by order ID
            (dir == 1 && price > pl[priceI]) ||
            (dir == 1 && price == pl[priceI] && (raw && entry[0] < pl[0]))
          ))
            insertIndex = i
            break
          end
        end

        # add
        if (insertIndex == -1)
          side.push(entry)
        else
          side.insert(insertIndex, entry)
        end

        return true
      end
    end
  end
end