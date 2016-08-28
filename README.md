# Physiqual
Ruby Engine for merging multiple data sources with diary questionnaire data

[![Code Climate](https://codeclimate.com/github/roqua/physiqual/badges/gpa.svg)](https://codeclimate.com/github/roqua/physiqual) [![Test Coverage](https://codeclimate.com/github/roqua/physiqual/badges/coverage.svg)](https://codeclimate.com/github/roqua/physiqual/coverage) [![Dependency Status](https://gemnasium.com/roqua/physiqual.svg)](https://gemnasium.com/roqua/physiqual) [![Circle CI](https://circleci.com/gh/roqua/physiqual/tree/master.svg?style=svg)](https://circleci.com/gh/roqua/physiqual/tree/master)
## Requirements
Physiqual requires the following additional software for caching:
* A Redis database
* A Cassandra database

Make sure the Cassandra database has a keyspace set up for use in Physiqual.

## Installation
Add Physiqual to your Gemfile. Currently Physiqual is not yet on RubyGems, this will happen after Physiqual is in a more stable beta state.

```ruby
  gem 'physiqual', github: 'roqua/physiqual'
```

Install the dependencies by running:
```ruby
  bundle
```

Initialize the database
``` ruby
  bundle exec rake db:setup
```

Mount the engine in the `config/routes.rb` file (in the `Rails.application.routes.draw` block)
``` ruby
  mount Physiqual::Engine => '/physiqual'
```

## Configuration
First create your an application on Google and Fitbit with the correct access levels and copy the key and ID from those services. Create initializer in `config/initializers/physiqual.rb` and add the configuration as follows, using the ID and secret retrieved from the services:

```ruby
Physiqual.configure do |config|
  # Google API tokens
  config.google_client_id     = ENV['GOOGLE_CLIENT_ID']
  config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']

  # Fitbit oauth tokens
  config.fitbit_client_id     = ENV['FITBIT_CLIENT_ID']
  config.fitbit_client_secret = ENV['FITBIT_CLIENT_SECRET']

  # Host settings
  config.host_url             = ENV['HOST_URL'] || 'physiqual.dev'
  config.host_protocol        = ENV['HOST_PROTOCOL'] || 'http'

  # Cassandra settings
  config.cassandra_username   = ENV['CASSANDRA_USERNAME'] || ''
  config.cassandra_password   = ENV['CASSANDRA_PASSWORD'] || ''
  config.cassandra_host_urls  = (ENV['CASSANDRA_HOST_URLS'] || 'physiqual.dev').split(' ')
  config.cassandra_keyspace   = ENV['CASSANDRA_KEYSPACE']
  
  # Redis settings
  config.redis_url            = ENV['REDIS_URL']

  # EMA Settings
  config.measurements_per_day           = 3 # Number of measurements per day, from the end of day downwards
  config.interval                       = 6 # Number of hours between measurements
  config.hours_before_first_measurement = 6 # How many hours before the first measurement each day should be included

  # Imputation
  # List of imputers to use, prefix with Physiqual::Imputers::, choose from:
  # - CatMullImputer
  # - KNearestNeighborImputer
  # - LastObservationCarriedForwardImputer
  # - MeanImputer
  # - SplineImputer
  # - MockImputer (doesn't actually impute).
  config.imputers             = [Physiqual::Imputers::CatMullImputer]
end
```

On the machine(s) that will handle caching, install Physiqual as well. Then run the following:
```bash
  bundle exec sidekiq
```
This will allow Physiqual to cache data asynchronously to your Cassandra database.

Now you should be able to start your server.

## Dummy
If you would like to run the dummy application, make a full checkout of Physiqual
```bash
  git clone git@github.com:roqua/physiqual.git --shallow
  bundle install
  bundle exec rake db:setup
```

And `cd` to `spec/dummy`. From this directory you can either run `bundle exec rails s` or create an apache v-host on passenger to run the server, for example:

```bash
  cd /etc/apache2/other
  touch physiqual.dev.vhost.conf
```

And add to this file a virtualhost configuration, for example:

```bash
<VirtualHost *:80>
  ServerName physiqual.dev
  ServerAdmin info@physiqual.dev
  DocumentRoot "<YOUR DIRECTORY>/physiqual/spec/dummy/public"
  RailsEnv development
  PassengerRuby /Users/frbl/.rvm/gems/ruby-2.2.1/wrappers/ruby
  <Directory "<YOUR DIRECTORY>/physiqual/spec/dummy/public">
    Options FollowSymLinks Multiviews
    MultiviewsMatch Any
    AllowOverride None
    Require all granted
  </Directory>
</VirtualHost>
```

you should now be able to surf to, for example: `http://physiqual.dev/oauth_session/google/authorize?email=a`

## Troubleshooting

You might run into some issues with regards to SSL warnings and errors. In that case, add the curl ca certificates to the environment variables, e.g., in osx:
```bash
  SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt
```

If your system has no SSL_CERT_FILE, you can get one from http://curl.haxx.se/ca/cacert.pem
