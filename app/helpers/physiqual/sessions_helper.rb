module Physiqual
  module SessionsHelper
    include ApplicationHelper
    def current_user
      @current_user ||= User.find_by_user_id(user_session)
    end

    def check_token
      tokens = current_user.physiqual_tokens

      fail Errors::NoTokenExistsError if tokens.blank? || tokens.none?(&:complete?)
    end

    def find_token
      @token = Token.provider_token params[:provider], current_user
      fail Errors::NoTokenExistsError if @token.nil?
    end
  end
end
