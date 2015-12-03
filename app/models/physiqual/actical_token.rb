module Physiqual
  class ActicalToken < MockToken
    def self.csrf_token
      'actical'
    end
  end
end
