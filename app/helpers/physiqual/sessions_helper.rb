module Physiqual
  module SessionsHelper
    include Physiqual::ApplicationHelper
    def current_user
      @current_user ||= User.find_by_user_id(user_session)
    end

    def check_token
      token = current_user.physiqual_token
      raise Errors::NoTokenExistsError if token.blank? || !token.complete?
    end

    def find_token
      @token = Token.find_provider_token params[:provider], current_user
      raise Errors::NoTokenExistsError if @token.nil?
    end
  end
end
