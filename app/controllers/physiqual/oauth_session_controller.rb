require 'oauth2'
module Physiqual
  class OauthSessionController < ApplicationController
    include OauthSessionHelper

    before_filter :sanitize_params, only: [:authorize, :callback]
    before_filter :sanitize_export_params, only: [:index]

    before_filter :check_token, only: :index
    before_filter :find_or_create_token, only: :authorize
    before_filter :find_token, only: :callback

    rescue_from Errors::EmailNotFoundError, with: :email_not_found
    rescue_from Errors::NoTokenExistsError, with: :no_token_exists
    rescue_from Errors::ServiceProviderNotFoundError, with: :service_provider_not_found

    def index
      frank = false
      if frank
        first_measurement = Time.new(2015, 8, 3, 10, 00).in_time_zone
      else
        first_measurement = Time.new(2015, 7, 15, 10, 30).in_time_zone
      end
      # session = Sessions::TokenAuthorizedSession.new(current_user.google_tokens.first.token, GoogleToken.base_uri)
      # session = Sessions::TokenAuthorizedSession.new(current_user.fitbit_tokens.first.token, FitbitToken.base_uri)

      # render json: DataServices::GoogleService.new(session).steps(from, to) and return
      # render json: DataServices::FitbitService.new(session).calories(from, to) and return

      number_of_days = 30
      respond_to_formats(first_measurement, number_of_days)
      # render json: FitbitService.new(current_user.fitbit_tokens.first).steps(from, to)
      # render json: FitbitService.new(current_user.fitbit_tokens.first).heart_rate(from, to)
    end

    def authorize
      redirect_url = @token.class.build_authorize_url(
        callback_oauth_session_index_url(provider: @token.class.csrf_token)
      )
      redirect_to redirect_url
    end

    def callback
      Rails.logger.info @token.inspect
      @token.retrieve_token!(params[:code], callback_oauth_session_index_url)
      redirect_to oauth_session_index_path state: params[:state]
    end
  end
end
