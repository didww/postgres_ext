source "https://rubygems.org"

gemspec :path => '..'

gem "activerecord", "~> 5.1.4"
gem "pg", "~> 0.15"

unless ENV['CI'] || RUBY_PLATFORM =~ /java/
  gem 'byebug'
end
