require 'jquery-rails'
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
    mattr_accessor :use_night
    mattr_accessor :imputers
  end

  def self.configure(&_block)
    yield self
  end

  class Engine < ::Rails::Engine
    isolate_namespace Physiqual

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
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
