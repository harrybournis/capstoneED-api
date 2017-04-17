source 'https://rubygems.org'
ruby '2.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.19.0'
# Use Puma as the app server
#gem 'puma', '~> 3.6'

# Unicorn server to fix issues with Vagrant freezing
gem 'unicorn', '~> 5.3'
gem 'unicorn-rails', '~> 2.2', '>= 2.2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 0.4.0'

# json serialization
gem 'json', '~> 2.0', '>= 2.0.2'
gem 'active_model_serializers', '~> 0.10.2'

# Authentication
gem 'jwt', '~> 1.5', '>= 1.5.4'
gem 'devise', '~> 4.2'
gem 'oauth2', '~> 1.2'

# Logging
gem 'lograge', '~> 0.4.1'

gem 'factory_girl_rails', '~> 4.7'
gem 'timecop', '~> 0.8.1'

# Generate Fake Data
gem 'faker', '~> 1.7', '>= 1.7.3'

# Generate Random Colors
gem 'color-generator', '~> 0.0.4'

# Validations
gem 'dry-validation', '~> 0.10.5'

# Validate JSON schema
gem 'json-schema', '~> 2.8'

# Chain Services
gem 'waterfall', '~> 1.0', '>= 1.0.5'

# Calculate time difference
gem 'time_difference', '~> 0.5.0'

# YARD documentation for ActiveRecord classes
gem 'yard-activerecord', '~> 0.0.16'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5', '>= 3.5.1'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'spring-commands-rspec', '~> 1.0', '>= 1.0.4'

  gem 'benchmark-ips', '~> 2.7', '>= 2.7.1'
  gem 'dotenv-rails', '~> 2.1', '>= 2.1.1' # read environment variables from a .env file in root
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'pry' # testing

  #gem 'faker', '~> 1.6', '>= 1.6.6' # generate dummy data

  gem 'letter_opener', '~> 1.4', '>= 1.4.1' # email opens in the browser

  gem 'awesome_print', '~> 1.7'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  gem 'vcr', '~> 3.0', '>= 3.0.3'
  gem 'db-query-matchers', '~> 0.6.0'
  gem 'pry-byebug', '~> 3.4'
  gem 'database_cleaner', '~> 1.5', '>= 1.5.3'
  gem 'simplecov', '~> 0.14.1' # display test coverage
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
