module Physiqual
  class ApplicationController < ActionController::Base
    include ApplicationHelper

    def no_token_exists
      render status: 404, plain: 'ERROR: No token of the specified service ' \
                                 'provider exists for the current user.'
    end

    def service_provider_not_found
      render status: 404, plain: 'ERROR: The specified service provider does not exist ' \
                                 '(or no service provider was specified).'
    end

    def no_session_exists
      render status: 404, plain: 'ERROR: Session token for user was not set (physiqual_user_id).'
    end

    def invalid_params(exception)
      render status: 404, plain: 'ERROR: The provided params are incorrect or not specified ' \
                                  "(#{exception.message})"
    end
  end
end
