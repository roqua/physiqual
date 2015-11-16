module Physiqual
  class SessionsController < ApplicationController
    # TODO: rename helper
    include OauthSessionHelper
    before_filter :find_token, only: :create

    rescue_from Errors::ServiceProviderNotFoundError, with: :service_provider_not_found
    rescue_from Errors::NoTokenExistsError, with: :no_token_exists

    def new
    end

    def create
      reset_session
      auth = request.env['omniauth.auth']
      Rails.logger.info "OmniAuth info: #{auth.to_yaml}"

      @token.update_attributes!(
          token: auth['credentials']['token'],
          refresh_token: auth['credentials']['refresh_token'],
          valid_until: Time.at(auth['credentials']['expires_at']).in_time_zone
      )

      redirect_to session.delete('physiqual_return_url')
    end

    def authorize
      user = User.find_or_create_by(user_id: session['physiqual_user_id'])
      provider = params[:provider]
      token = Token.find_or_create_provider_token(provider, user)

      unless token.complete?
        session['physiqual_return_url'] = params[:return_url]
        omniauth_url = "/physiqual/auth/#{provider}"
        redirect_to omniauth_url and return
      end

      redirect_to params[:return_url]
    end

    def failure
      redirect_to new_session_url,
                  flash: {error: 'Sorry, there was something wrong with your login attempt. Please try again.'}
    end

    def destroy
      reset_session
      flash[:notice] = 'Logged out.'
      redirect_to root_url
    end
  end
end
