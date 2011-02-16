# Copyright 2011 DedaSys LLC - David N. Welton <davidw@dedasys.com>

require 'open-uri'
require 'json'
require 'cgi'

# This is a Ruby interface to the JSON results provided by the Google
# Screener.  It's not an official API.

class GoogleScreener

  BASE_URI = "http://www.google.com/finance?"
  BASE_PARAMS = {
    :gl       => "us",
    :hl       => "en",
    :output   => "json",
    :restype  => "company",
    :sortas   => "Price52WeekPercChange",
    :desc     => 1,
    :noIL     => 1,
    :start    => 0,
    :num      => 20
  }

  # Known options in the screener.

  KNOWN_OPTIONS = [
                   :MarketCap,
                   :PE,
                   :DividendYield,
                   :Price52WeekPercChange,
                   :Price13WeekPercChange,
                   :NetIncomeGrowthRate5Years,
                   :QuoteLast
                  ]

  SCREENER_MIN = {
    :MarketCap                  => 10_000_000,
    :PE                         => 0,
    :DividendYield              => 0.01,
    :Price52WeekPercChange      => -100.00,
    :NetIncomeGrowthRate5Years  => -100.00,
    :QuoteLast                  => 0.00
  }
  SCREENER_MAX = {
    :MarketCap                  => 1_500_000_000_000,
    :PE                         => 100,
    :DividendYield              => 38.03,
    :Price52WeekPercChange      => -5,
    :NetIncomeGrowthRate5Years  => 500,
    :QuoteLast                  => 150000
  }

  class Result
    attr_reader :name, :symbol, :values
    def initialize(result)
      @name = result['title']
      @symbol = result['ticker']
      @values = Hash[result['columns'].map { |c| [c['field'], c['value']] }]
    end
  end

  attr_reader :results

  def initialize(options = {})
    merged_minimums = SCREENER_MIN.merge(options[:min] || {})
    merged_maximums = SCREENER_MAX.merge(options[:max] || {})
    option_string   = merged_minimums.map do |key, value|
      if !KNOWN_OPTIONS.include?(key)
        raise "Unknown 'min' option: #{key}"
      end
      "(#{CGI.escape(key.to_s)} > #{value.to_f})"
    end.join(" & ")
    option_string  += " & "
    option_string  += merged_maximums.map do |key, value|
      if !KNOWN_OPTIONS.include?(key)
        raise "Unknown 'max' option: #{key}"
      end
      "(#{CGI.escape(key.to_s)} < #{value.to_f})"
    end.join(" & ")
    query   = "((exchange:NYSE) OR (exchange:NASDAQ) OR (exchange:AMEX)) [#{option_string}]"
    @params = BASE_PARAMS.merge(:q => query)
  end

  def sort_as(how)
    @params.merge!(:sortas => how)
    self
  end

  def fetch
    @results = get_data.map { |res| Result.new(res) }
  end

  private

  def get_data
    JSON.parse(open(uri).read)['searchresults']
  end

  def uri
    BASE_URI + query_string
  end

  def query_string
    @params.map { |key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join("&")
  end

end
