require 'jquery-rails'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-fitbit-oauth2'
module Physiqual
  class << self
    mattr_accessor :google_client_id
    mattr_accessor :google_client_secret
    mattr_accessor :fitbit_client_id
    mattr_accessor :fitbit_client_secret
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

    initializer 'physiqual.append_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    initializer 'physiqual.omniauth', before: :build_middleware_stack do |app|
      app.middleware.use OmniAuth::Builder do
        configure do |config|
          config.path_prefix = '/physiqual/auth'
        end

        provider :google_oauth2, Physiqual.google_client_id, Physiqual.google_client_secret, prompt: 'consent'
        provider :fitbit_oauth2, Physiqual.fitbit_client_id, Physiqual.fitbit_client_secret,
                 scope: 'activity heartrate location nutrition profile settings sleep social weight'
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
