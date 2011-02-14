Gem::Specification.new do |s|
  s.name = "google-screener"
  s.summary = "Ruby interface to Google Stock Screener: http://www.google.com/finance/stockscreener"
  s.description = "Ruby interface to Google Stock Screener: http://www.google.com/finance/stockscreener"
  s.version = "0.0.1"
  s.author = "David N. Welton"
  s.email = "davidw@dedasys.com"
  s.homepage = "http://github.com/davidw/google-screener"
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.8'
  s.files = Dir['**/**']
  s.test_files = Dir["test/test*.rb"]
  s.has_rdoc = false
end
