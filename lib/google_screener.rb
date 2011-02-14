# Copyright 2011 DedaSys LLC - David N. Welton <davidw@dedasys.com>

require 'open-uri'
require 'json'

# This is a Ruby interface to the JSON results provided by the Google
# Screener.  It's not an official API.

class GoogleScreener

  class Result
    attr_reader :name, :symbol, :values
    def initialize(result)
      @name = result['title']
      @symbol = result['ticker']
      @values = Hash[result['columns'].map { |c| [c['field'], c['value']] }]
    end
  end

  attr_reader :results

  def initialize()
    # This query isn't actually used as-is; the 'q' gets replaced.
    @fullquery = [["gl", "us"], ["hl", "en"], ["output", "json"], ["start", "0"], ["num", "20"], ["noIL", "1"], ["q", "((exchange:NYSE) OR (exchange:NASDAQ) OR (exchange:AMEX)) [(MarketCap > 10000000 | MarketCap = 10000000) & (MarketCap < 1500000000000 | MarketCap = 1500000000000) & (PE > 0 | PE = 0) & (PE < 100 | PE = 100) & (DividendYield > 0.01 | DividendYield = 0.01) & (DividendYield < 38.03 | DividendYield = 38.03) & (Price52WeekPercChange > -97.77 | Price52WeekPercChange = -97.77) & (Price52WeekPercChange < -15 | Price52WeekPercChange = -15) & (TotalDebtToAssetsYear > 0 | TotalDebtToAssetsYear = 0) & (TotalDebtToAssetsYear < 0 | TotalDebtToAssetsYear = 0) & (NetIncomeGrowthRate5Years > -78.78 | NetIncomeGrowthRate5Years = -78.78) & (NetIncomeGrowthRate5Years < 419 | NetIncomeGrowthRate5Years = 419) & (QuoteLast > 0.03 | QuoteLast = 0.03) & (QuoteLast < 122811 | QuoteLast = 122811)]"], ["restype", "company"], ["sortas", "Price52WeekPercChange"], ["desc", "1"]]
    @url = "http://www.google.com/finance"
  end

  def fetch(querytype)
    query = make_query(querytype)

    # FIXME: 1.9 can use this: url = @url + "?&" + URI.encode_www_form(query)
    url = @url + "?&" + query.map { |x| "#{CGI.escape(x[0])}=#{CGI.escape(x[1])}" }.join("&")
    @results = JSON.parse(open(url).read)['searchresults'].map { |res| Result.new(res) }
  end

  private

  # QuotePercChange

  def make_query(querytype)
    query = "((exchange:NYSE) OR (exchange:NASDAQ) OR (exchange:AMEX)) [(MarketCap > 10000000 | MarketCap = 10000000) & (MarketCap < 1500000000000 | MarketCap = 1500000000000) & (PE > 0 | PE = 0) & (PE < 100 | PE = 100) & (DividendYield > 0.01 | DividendYield = 0.01) & (DividendYield < 38.03 | DividendYield = 38.03) & (#{querytype} > -200.00) & (#{querytype} < -15) & (TotalDebtToAssetsYear > 0 | TotalDebtToAssetsYear = 0) & (TotalDebtToAssetsYear < 0 | TotalDebtToAssetsYear = 0) & (NetIncomeGrowthRate5Years > -78.78 | NetIncomeGrowthRate5Years = -78.78) & (NetIncomeGrowthRate5Years < 419 | NetIncomeGrowthRate5Years = 419) & (QuoteLast > 0.03 | QuoteLast = 0.03) & (QuoteLast < 122811 | QuoteLast = 122811)]"
    sortas = querytype
    return @fullquery.map do |x|
      if x[0] == "q"
        ["q", query]
      elsif x[0] == "sortas"
        ["sortas", sortas] 
      else
        x
      end
    end
  end

end
