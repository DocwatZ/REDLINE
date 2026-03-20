source "https://rubygems.org"

ruby "3.2.3"

gem "rails", "~> 7.1.5"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

# Redis for ActionCable and caching
gem "redis", ">= 4.0.1"

# Authentication
gem "devise", "~> 4.9"
gem "bcrypt", "~> 3.1.7"

# JWT for LiveKit token generation
gem "jwt", "~> 2.8"

# HTTP client for external API calls
gem "faraday", "~> 2.7"

# Security — rate limiting
gem "rack-attack", "~> 6.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "web-console"
end

