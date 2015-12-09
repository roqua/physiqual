module Physiqual
  class ActicalToken < MockToken
    def self.csrf_token
      'actical'
    end

    def refresh_token
      'refresh'
    end

    def token
      'token'
    end
  end
end
