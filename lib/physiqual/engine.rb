require 'jquery-rails'
require 'virtus'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-fitbit-oauth2'
module Physiqual
  class << self
    mattr_accessor :google_client_id
    mattr_accessor :google_client_secret
    mattr_accessor :fitbit_client_id
    mattr_accessor :fitbit_client_secret

    # Cassandra settings
    mattr_accessor :enable_cassandra
    mattr_accessor :cassandra_username
    mattr_accessor :cassandra_password
    mattr_accessor :cassandra_host_urls
    mattr_accessor :cassandra_keyspace

    def cassandra_urls
      urls = cassandra_host_urls
      a = urls.split(' ') unless urls.blank?
      Rails.logger.info(urls)
      Rails.logger.info(a)
      a
    end

    mattr_accessor :cassandra_keyspace
    mattr_accessor :host_url
    mattr_accessor :host_protocol
    mattr_accessor :measurements_per_day
    mattr_accessor :interval
    mattr_accessor :hours_before_first_measurement
    mattr_accessor :imputers
  end

  def self.configure(&_block)
    yield self
  end

  def self.google_omniauth
  end

  class Engine < ::Rails::Engine
    isolate_namespace Physiqual
    engine_name 'physiqual'

    initializer 'physiqual.append_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer 'physiqual.omniauth', before: :build_middleware_stack do |app|
      app.middleware.use OmniAuth::Builder do
        provider :physiqual_google_oauth2, Physiqual.google_client_id, Physiqual.google_client_secret,
                 prompt: 'consent',
                 scope: GoogleToken.scope
        provider :physiqual_fitbit_oauth2, Physiqual.fitbit_client_id, Physiqual.fitbit_client_secret,
                 scope: FitbitToken.scope
      end
    end

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
