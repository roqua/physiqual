# physiqual
Ruby Engine for merging multiple datasources with diary questionnaire data

[![Code Climate](https://codeclimate.com/github/roqua/physiqual/badges/gpa.svg)](https://codeclimate.com/github/roqua/physiqual) [![Test Coverage](https://codeclimate.com/github/roqua/physiqual/badges/coverage.svg)](https://codeclimate.com/github/roqua/physiqual/coverage) [![Dependency Status](https://gemnasium.com/roqua/physiqual.svg)](https://gemnasium.com/roqua/physiqual) [![Circle CI](https://circleci.com/gh/roqua/physiqual/tree/master.svg?style=svg)](https://circleci.com/gh/roqua/physiqual/tree/master)

- physiqual.dev.vhost.conf aanmaken
- physiqual.dev in /etc/hosts zetten
- bi
- be rake db:setup
- be rails server
- touch .env

Create initializer in `config/initializers/physiqual.rb` and add the config as follows:
```ruby
Physiqual.configure do |config|
  config.google_client_id     = ENV['GOOGLE_CLIENT_ID']
  config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']
  config.fitbit_client_id     = ENV['FITBIT_CLIENT_ID']
  config.fitbit_client_secret = ENV['FITBIT_CLIENT_SECRET']

  config.host_url             = ENV['HOST_URL'] || 'physiqual.dev'
  config.host_protocol        = ENV['HOST_PROTOCOL'] || 'http'
end
```
You can either set the actual values here, or use environment values (like in the example).

HOST_URL=physiqual.dev
HOST_PROTOCOL=http
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
FITBIT_CLIENT_ID=
FITBIT_CLIENT_SECRET=
SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt

On production also define:
SECRET_KEY_BASE=some long string

If your system has no SSL_CERT_FILE, you can get one from http://curl.haxx.se/ca/cacert.pem

http://physiqual.dev/oauth_session/google/authorize?email=a
##### Google Fit integration
googleclient id en secret komt van console.developers.google.com
onder apis & auth

##### Fitbit integration
