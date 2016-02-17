module Physiqual
  class Token < ActiveRecord::Base
    self.table_name = 'physiqual_tokens'

    belongs_to :physiqual_user, class_name: 'Physiqual::User'
    validates :physiqual_user_id, presence: true
    validates_uniqueness_of :physiqual_user_id
    validates_presence_of :type

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
      raise 'Subclass does not implement csrf method'
    end

    def self.scope
      raise 'Subclass does not implement scope method'
    end

    def self.client_id
      raise 'Subclass does not implement client_id method'
    end

    def self.client_secret
      raise 'Subclass does not implement client_secret method'
    end

    def self.oauth_site
      raise 'Subclass does not implement oauth_site method'
    end

    def self.authorize_url
      raise 'Subclass does not implement authorize_url method'
    end

    def self.token_url
      raise 'Subclass does not implement token_url method'
    end

    def self.provider_type(provider)
      if provider == GoogleToken.csrf_token
        Physiqual::GoogleToken.to_s
      elsif provider == FitbitToken.csrf_token
        Physiqual::FitbitToken.to_s
      else
        raise Errors::ServiceProviderNotFoundError
      end
    end

    def self.find_provider_token(provider, user)
      resulting_token = user.physiqual_token
      return nil if resulting_token.blank? || resulting_token.type != provider_type(provider)
      resulting_token
    end

    def self.create_provider_token(provider:, user:)
      user.physiqual_token.destroy if user.physiqual_token
      user.create_physiqual_token(type: provider_type(provider))
    end

    def self.find_or_create_provider_token(provider, user)
      token = find_provider_token(provider, user)
      token = create_provider_token(provider: provider, user: user) if token.nil?
      token
    end
  end
end
