module Physiqual
  class User < ActiveRecord::Base
    self.table_name = 'physiqual_users'

    has_many :physiqual_tokens, foreign_key: 'physiqual_user_id', class_name: 'Physiqual::Token'
    has_many :google_tokens, foreign_key: 'physiqual_user_id', class_name: 'Physiqual::GoogleToken'
    has_many :fitbit_tokens, foreign_key: 'physiqual_user_id', class_name: 'Physiqual::FitbitToken'
    validates :user_id, presence: true

    def find_tokens(csrf_token)
      return nil unless csrf_token
      tokens.select { |x| x.class.csrf_token == csrf_token }
    end
  end
end
