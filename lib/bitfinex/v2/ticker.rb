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

    #  TBD
    def listen_ticker(pair="tBTCUSD", &block)
      raise BlockMissingError unless block_given?
      descriptors = [:pair, :dir, :rate, :type]
      register_channel pair: pair, channel: "ticker", descriptors: descriptors, &block
    end
  end
end
