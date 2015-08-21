class FitbitToken < Token
  def token(code, url)
    self.class.client.auth_code.get_token(code,
                                          redirect_uri: url,
                                          headers: { 'Authorization' => "Basic #{encode_key}" })
  end

  def refresh
    Rails.logger.info to_hash
    ENV['OAUTH_DEBUG'] = 'true'
    at = OAuth2::AccessToken.from_hash(self.class.client, to_hash)
    Rails.logger.info pp at.inspect
    at.refresh!(headers: { 'Authorization' => "Basic #{encode_key}" })
  end

  def self.base_uri
    'https://api.fitbit.com/1/user/-'
  end

  def self.scope
    'activity heartrate location nutrition profile settings sleep social weight'
  end

  def self.csrf_token
    'fitbit'
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
    '/oauth2/authorize'
  end

  def self.token_url
    '/oauth2/token'
  end
end
