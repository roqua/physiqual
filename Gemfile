source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'oauth2'

gem 'httparty'

gem 'dotenv-rails'

gem 'active_interaction', '~> 2.1.1'

# Imputation
gem 'spliner'
gem 'interpolator'

gem 'codeclimate-test-reporter', group: :test, require: nil

group :test do
  # Webmock is needed to disable any outgoing traffic
  gem 'webmock'
end

# Enable better error handling
group :development do
  gem 'meta_request', '~> 0.2.1', require: 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'spring-commands-rspec'

  gem 'rspec-rails', '~> 3.0'

  gem 'rubocop'

  # Freeze and change time for tests
  gem 'timecop'

  # vcr to capture service responses
  gem 'vcr'

  gem 'factory_girl_rails'
end
