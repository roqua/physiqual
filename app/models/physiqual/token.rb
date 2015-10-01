module Physiqual
  class Token < ActiveRecord::Base
    self.table_name = 'physiqual_tokens'

    belongs_to :physiqual_user, class_name: 'Physiqual::User'
    # validates :token, presence: true
    # validates :refresh_token, presence: true
    validates :physiqual_user_id, presence: true
    # validates :valid_until, presence: true

    def expired?
      valid_until.blank? || valid_until <= Time.now.in_time_zone
    end

    def refresh!
      access_token = refresh
      self.token = access_token.token
      self.refresh_token = access_token.refresh_token
      self.valid_until = Time.at(access_token.expires_at).in_time_zone
      save!
    end

    def refresh
      OAuth2::AccessToken.from_hash(self.class.client, to_hash).refresh!
    end

    def self.client
      OAuth2::Client.new(client_id, client_secret, site: oauth_site, authorize_url: authorize_url, token_url: token_url)
    end

    def self.build_authorize_url(redirect_url)
      client.auth_code.authorize_url(redirect_uri: redirect_url,
                                     scope: scope,
                                     access_type: 'offline',
                                     approval_prompt: 'force',
                                     state: csrf_token
                                    )
    end

    def to_hash
      token_hash = {}
      token_hash['token_type'] = 'Bearer'
      token_hash[:access_token] = token
      token_hash[:refresh_token] = refresh_token
      token_hash[:expires_at] = valid_until.to_i
      token_hash
    end

    def retrieve_token!(code, url)
      # This is needed for fitbit
      access_token = get_token(code, url)
      self.token = access_token.token
      self.refresh_token = access_token.refresh_token
      self.valid_until = Time.at(access_token.expires_at).in_time_zone
      save!
    end

    def encode_key
      Base64.encode64("#{self.class.client_id}:#{self.class.client_secret}")
    end

    def get_token(code, url)
      self.class.client.auth_code.get_token(code, redirect_uri: url)
    end

    def complete?
      complete = !token.blank?
      complete &= !refresh_token.blank?
      complete
    end

    def self.csrf_token
      fail 'Subclass does not implement csrf method'
    end

    def self.scope
      fail 'Subclass does not implement scope method'
    end

    def self.client_id
      fail 'Subclass does not implement client_id method'
    end

    def self.client_secret
      fail 'Subclass does not implement client_secret method'
    end

    def self.oauth_site
      fail 'Subclass does not implement oauth_site method'
    end

    def self.authorize_url
      fail 'Subclass does not implement authorize_url method'
    end

    def self.token_url
      fail 'Subclass does not implement token_url method'
    end
  end
end
