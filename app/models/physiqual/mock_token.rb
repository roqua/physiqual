module Physiqual
  class MockToken < Token
    def self.base_uri
      ''
    end

    def self.scope
      ''
    end

    def self.client_id
      ''
    end

    def self.client_secret
      ''
    end

    def self.oauth_site
      ''
    end

    def self.authorize_url
      ''
    end

    def self.token_url
      ''
    end

    def complete?
      true
    end

    def expired?
      false
    end
  end
end
