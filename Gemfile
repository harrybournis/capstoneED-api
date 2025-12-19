source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.7'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.10"

gem 'pg', '~> 1.6', '>= 1.6.2'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem 'active_model_serializers', '~> 0.10.16'

gem 'jwt', '~> 3.1', '>= 3.1.2'

gem 'devise', '~> 4.9', '>= 4.9.4'

gem 'oauth2', '~> 2.0', '>= 2.0.18'

gem 'faker', '~> 3.5', '>= 3.5.3'

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "bootsnap", require: false

# gem 'dry-validation', '~> 0.10.5'
gem 'dry-validation', '~> 1.11', '>= 1.11.1'

gem 'json-schema', '~> 6.0'

gem 'waterfall', '~> 1.3'

# gem 'time_difference', '~> 0.7.0'

gem 'yard-activerecord', '~> 0.0.17'

gem 'whenever', '~> 1.1', '>= 1.1.1'

gem 'mutex_m', '~> 0.3.0'
gem 'ostruct', '~> 0.6.3'
gem 'benchmark', '~> 0.5.0'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'timecop', '~> 0.9.10'
  gem 'benchmark-ips'
  gem 'dotenv-rails' # read environment variables from a .env file in root
end

group :development do
  gem 'pry' # testing
  gem 'letter_opener' # email opens in the browser
end

group :test do
  gem 'shoulda-matchers', '~> 6.5'
  gem 'vcr'
  gem 'db-query-matchers'
  gem 'pry-byebug'
  gem 'database_cleaner'
  gem 'simplecov' # display test coverage
  gem 'whenever-test' # test whenever gem
end

