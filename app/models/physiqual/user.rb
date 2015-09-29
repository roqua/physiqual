module Physiqual
  class User < ActiveRecord::Base
    self.table_name = 'physiqual_users'

    has_many :tokens
    has_many :google_tokens
    has_many :fitbit_tokens
    validates :email, presence: true
  
    def find_tokens(csrf_token)
      return nil unless csrf_token
      tokens.select { |x| x.class.csrf_token == csrf_token }
    end
  end
end
