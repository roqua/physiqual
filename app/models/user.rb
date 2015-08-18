class User < ActiveRecord::Base
  has_many :tokens
  has_many :google_tokens
  has_many :fitbit_tokens
  validates :email, presence: true
end
