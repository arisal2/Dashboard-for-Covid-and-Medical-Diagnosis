# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.2.0', '< 3.3.0'

# Shim to load environment variables from .env into ENV in development.
gem 'dotenv-rails', groups: %i[development test]

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'

# Use Puma as the app server
gem 'puma', '~> 6.4'

# Modern asset pipeline
gem 'importmap-rails'
gem 'propshaft'

# Use dartsass for SCSS compilation
gem 'dartsass-rails', '~> 0.5'

# Hotwire - modern interactive applications
gem 'stimulus-rails'
gem 'turbo-rails'

# Build JSON APIs with ease
gem 'jbuilder', '~> 2.11'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Authentication
gem 'devise', '~> 4.9'

# HTTP client
gem 'faraday', '~> 2.14'
gem 'rack-cors'

# Background jobs
gem 'connection_pool', '~> 2.4'
gem 'sidekiq', '~> 7.2'
gem 'sidekiq-cron', '~> 2.4'

# UI & Frontend
gem 'bootstrap', '~> 5.3'
# gem 'sassc-rails', '~> 2.1' # REMOVED: Conflicting with dartsass-rails
gem 'font-awesome-sass', '~> 6.5'
gem 'jquery-rails'

# Data tables
gem 'ajax-datatables-rails', '~> 1.4'
gem 'jquery-datatables', '~> 1.10'

# Charts
gem 'chartkick', '~> 5.0'

# Bulk import
gem 'activerecord-import', '~> 1.5'

# Email validation
gem 'truemail', '~> 3.3'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # Debugging
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  # Testing
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rspec-rails', '~> 6.1'
  gem 'truemail-rspec', require: false

  # Code quality
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
end

group :development do
  gem 'brakeman', require: false

  # Access an interactive console on exception pages
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler'

  gem 'listen', '~> 3.9'
end

group :test do
  # System testing
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.16'

  # HTTP mocking
  gem 'webmock', '~> 3.19'

  # JUnit format for CI
  gem 'rspec_junit_formatter', '~> 0.6'
end
