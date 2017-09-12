# coding: utf-8

module Bitfinex
  module V2::TickerClient

    # Gives innermost bid and asks and information on
    # the most recent trade, as well as high, low and
    # volume of the last 24 hours.
    #
    # @param symbols a list of symbols
    # @return [Hash]
    # @example:
    #   client.ticker("tBTCUSD","tLTCUSD","fUSD")
    def ticker(*symbols)
      if symbols.size == 1
        get("ticker/#{symbols.first}").body
      else
        get("tickers", symbols: "#{symbols.flatten.join(",")}").body
      end
    end

    # Call the specified block passing tickers, it uses websocket
    #
    # @param pair [string]
    # @param block [Block] The code to be executed when a new ticker is sent by the server
    #
    # Documentation:
    #    https://docs.bitfinex.com/v2/reference#ws-public-ticker
    #
    # @example:
    #   client.listen_ticker do |tick|
    #     puts tick.inspect
    #   end
    def listen_ticker(pair="tBTCUSD", &block)
      raise BlockMissingError unless block_given?
      register_channel pair: pair, channel: "ticker",  &block
    end

    # Provides a way to access charting candle info
    #
    # @param symbol [string]
    # @param time_frame [string] default '1m' - see doc for list of options
    #
    # Documentation:
    #    https://docs.bitfinex.com/v2/reference#ws-public-candle
    #
    # @example:
    # client.listen_candles("tBTCUSD","1m") do |candle|
    #   puts "high #{candle[1][8]} | low #{candle[1][9]}"
    # end
    def listen_candles(symbol="tBTCUSD", time_frame="1m", &block)
      raise BlockMissingError unless block_given?
      key = "trade:#{time_frame}:#{symbol}"
      register_channel key: key, channel: 'candles', &block
    end

  end
end
