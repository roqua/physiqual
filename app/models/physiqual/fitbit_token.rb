module Physiqual
  class FitbitToken < Token
    def get_token(code, url)
      self.class.client.auth_code.get_token(code,
                                            redirect_uri: url,
                                            headers: { 'Authorization' => "Basic #{encode_key}" })
    end

    def refresh
      oauth_access_token = OAuth2::AccessToken.from_hash(self.class.client, to_hash)
      oauth_access_token.refresh!(headers: { 'Authorization' => "Basic #{encode_key}" })
    end

    def self.base_uri
      'https://api.fitbit.com/1/user/-'
    end

    def self.scope
      'activity heartrate location nutrition profile settings sleep social weight'
    end

    def self.csrf_token
      'physiqual_fitbit_oauth2'
    end

    def self.friendly_name
      'Fitbit'
    end

    def self.client_id
      ENV['FITBIT_CLIENT_ID']
    end

    def self.client_secret
      ENV['FITBIT_CLIENT_SECRET']
    end

    def self.oauth_site
      'https://api.fitbit.com'
    end

    def self.authorize_url
      'https://www.fitbit.com/oauth2/authorize'
    end

    def self.token_url
      '/oauth2/token'
    end
  end
end
