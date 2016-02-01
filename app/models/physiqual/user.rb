module Physiqual
  class User < ActiveRecord::Base
    self.table_name = 'physiqual_users'

    has_one :physiqual_token, foreign_key: 'physiqual_user_id', class_name: 'Physiqual::Token'
    validates :user_id, presence: true
  end
end
