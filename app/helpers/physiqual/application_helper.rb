module Physiqual
  module ApplicationHelper
    def user_session
      @user_id ||= session['physiqual_user_id']
      raise Errors::NoSessionExistsError if @user_id.nil?
      @user_id
    end
  end
end
