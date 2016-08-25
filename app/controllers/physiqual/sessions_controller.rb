module Physiqual
  class SessionsController < Physiqual::ApplicationController
    include Physiqual::SessionsHelper
    before_filter :find_token, only: :create

    rescue_from Errors::ServiceProviderNotFoundError, with: :service_provider_not_found
    rescue_from Errors::NoTokenExistsError, with: :no_token_exists
    rescue_from Errors::NoSessionExistsError, with: :no_session_exists

    def create
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
      return_url = sessions_params[:return_url] || '/'
      user = Physiqual::User.find_or_create_by(user_id: user_session)
      provider = sessions_params[:provider]
      token = Physiqual::Token.find_or_create_provider_token(provider, user)

      unless token.complete?
        session['physiqual_return_url'] = return_url
        omniauth_url = "#{Rails.application.routes.url_helpers.physiqual_path}/auth/#{provider}"
        redirect_to omniauth_url and return
      end

      redirect_to return_url
    end

    # TODO: MOET NOG!
    def failure
      redirect_to new_session_url,
                  flash: { error: 'Sorry, there was something wrong with your login attempt. Please try again.' }
    end

    private

    def sessions_params
      params.permit(:provider, :return_url)
    end
  end
end
