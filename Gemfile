source "https://rubygems.org"

gem "bootsnap", require: false
gem "blueprinter", "~> 1.1", ">= 1.1.2"
gem "dry-schema", "~> 1.14"
gem "importmap-rails"
gem "minitest-reporters", "~> 1.7", ">= 1.7.1"
gem "minitest-rails", "~> 7.2.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rails", "~> 7.2.1"
gem "sprockets-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development do
  gem "web-console"
end

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
  gem "pry-nav", "~> 1.0.0"
  gem "pry-rails", "~> 0.3.11"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "timecop", "~> 0.9.10"
end
