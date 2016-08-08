source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18.4'
# Use Puma as the app server
gem 'puma', '~> 3.6'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# json serialization
gem 'active_model_serializers', '~> 0.10.2'

# Authentication
gem 'jwt', '~> 1.5', '>= 1.5.4'

gem 'oauth2', '~> 1.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5', '>= 3.5.1'
  gem 'spring-commands-rspec', '~> 1.0', '>= 1.0.4'
  gem 'factory_girl_rails', '~> 4.7'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'pry' # testing

  gem 'faker', '~> 1.6', '>= 1.6.6' # generate dummy data

  gem 'letter_opener', '~> 1.4', '>= 1.4.1' # email opens in the browser
end

group :test do
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  gem 'vcr', '~> 3.0', '>= 3.0.3'
  #gem 'airborne', '~> 0.2.6'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
