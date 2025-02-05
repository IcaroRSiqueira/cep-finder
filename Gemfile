source "https://rubygems.org"

gem "faraday"
gem "rails", "~> 8.0.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "brakeman", require: false
  gem "byebug"
  gem "factory_bot_rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-doc"
  gem "rspec-json_expectations"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec"
end

group :test do
  gem "webmock"
end
