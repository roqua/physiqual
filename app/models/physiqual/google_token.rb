module Physiqual
  class GoogleToken < Token
    def self.base_uri
      'https://www.googleapis.com/fitness/v1/users/me'
    end

    def self.scope
      'https://www.googleapis.com/auth/fitness.activity.read '\
      'https://www.googleapis.com/auth/fitness.body.read '\
      'https://www.googleapis.com/auth/fitness.location.read '\
      'profile '\
      'email'
    end

    def self.csrf_token
      'physiqual_google_oauth2'
    end

    def self.friendly_name
      'Google Fit'
    end

    def self.client_id
      ENV['GOOGLE_CLIENT_ID']
    end

    def self.client_secret
      ENV['GOOGLE_CLIENT_SECRET']
    end

    def self.oauth_site
      'accounts.google.com'
    end

    def self.authorize_url
      '/o/oauth2/auth'
    end

    def self.token_url
      '/o/oauth2/token'
    end
  end
end
