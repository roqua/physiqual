module Physiqual
  class User < ActiveRecord::Base
    self.table_name = 'physiqual_users'

    has_one :physiqual_token, foreign_key: 'physiqual_user_id', class_name: 'Physiqual::Token'
    validates :user_id, presence: true

    def find_tokens(csrf_token)
      return nil unless csrf_token
      tokens.select { |x| x.class.csrf_token == csrf_token }
    end
  end
end
