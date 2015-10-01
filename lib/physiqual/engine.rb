require 'jquery-rails'
module Physiqual
  class << self
    mattr_accessor :google_client_id
    mattr_accessor :google_client_secret
    mattr_accessor :fitbit_client_id
    mattr_accessor :fitbit_client_secret
    mattr_accessor :host_url
    mattr_accessor :host_protocol
  end

  def self.configure(&block)
    yield self
  end

  class Engine < ::Rails::Engine
    isolate_namespace Physiqual

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
