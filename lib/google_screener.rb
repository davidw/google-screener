# Copyright 2011 DedaSys LLC - David N. Welton <davidw@dedasys.com>

require 'open-uri'
require 'json'
require 'cgi'

# This is a Ruby interface to the JSON results provided by the Google
# Screener.  It's not an official API.

class GoogleScreener

  BASE_URI = "http://www.google.com/finance?"
  
  # We don't yet know what :desc and :noIL do, also other :restype options are unknown.
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
  
  # Defaults for the query. Probably these values are too specific?
  DEFAULTS = {
    :max => {
      :MarketCap                  => 1_500_000_000_000,
      :PE                         => 100,
      :DividendYield              => 50,
      :Price52WeekPercChange      => -5,
      :NetIncomeGrowthRate5Years  => 500,
      :QuoteLast                  => 150000
    },
    :min => {
      :MarketCap                  => 10_000_000,
      :PE                         => 0,
      :DividendYield              => 0,
      :Price52WeekPercChange      => -100,
      :NetIncomeGrowthRate5Years  => -100,
      :QuoteLast                  => 0
    }
  }
  
  EXCHANGES = "(exchange:NYSE OR exchange:NASDAQ OR exchange:AMEX)"

  class Result
    attr_reader :name, :symbol, :values
    def initialize(result)
      @name     = result['title']
      @symbol   = result['ticker']
      @exchange = result['exchange']
      @values   = Hash[result['columns'].map { |c| [c['field'], c['value']] }]
    end
  end

  attr_reader :results, :count

  def initialize(options = {})
    string  = screen(:min, options[:min] || {}) + "&" + screen(:max, options[:max] || {})
    query   = "#{EXCHANGES} [#{string}]"
    @params = BASE_PARAMS.merge(:q => query)
  end

  def sort_as(how)
    @params.merge!(:sortas => how)
    self
  end
  
  def start(n)
    @params.merge!(:start => n)
    self
  end
  
  def limit(n)
    @params.merge!(:num => n)
    self
  end

  def fetch
    @count    = response['num_company_results']
    @results  = response['searchresults'].map { |stock| Result.new(stock) }
    remove_instance_variable(:@params)
    remove_instance_variable(:@response)
    self
  end

  private
  
  def screen(type, options)
    comparator = (type == :min ? ">" : "<")
    DEFAULTS[type].merge(options)
    .keep_if {|k, v| KNOWN_OPTIONS.include?(k) }
    .map { |k, v| "#{CGI.escape(k.to_s)}#{comparator}#{v.to_f}" }
    .join("&")
  end

  def response
    @response ||= JSON.parse(open(uri).read)
  end

  def uri
    BASE_URI + query_string
  end

  def query_string
    @params.map { |key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join("&")
  end

end
