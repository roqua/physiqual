module Physiqual
  module SessionsHelper
    def current_user
      @current_user ||= User.find_by_user_id(session['physiqual_user_id'])
    end

    def no_token_exists
      render status: 404, plain: 'ERROR: No token of the specified service ' \
                                 'provider exists for the current user.'
    end

    def service_provider_not_found
      render status: 404, plain: 'ERROR: The specified service provider does not exist ' \
                                 '(or no service provider was specified).'
    end

    def check_token
      tokens = current_user.physiqual_tokens

      fail Errors::NoTokenExistsError if tokens.blank? || tokens.none? { |token| token.complete? }
    end

    def find_token
      @token = Token.provider_token params[:provider], current_user
      fail Errors::NoTokenExistsError if @token.nil?
    end
  end
end
