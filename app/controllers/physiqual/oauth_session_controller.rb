require 'oauth2'
module Physiqual
  class OauthSessionController < ApplicationController
    before_filter :sanitize_params, only: [:authorize, :callback]
    before_filter :sanitize_export_params, only: [:index]

    before_filter :check_token, only: :index
    before_filter :find_or_create_token, only: :authorize
    before_filter :find_token, only: :callback

    rescue_from Errors::EmailNotFoundError, with: :email_not_found
    rescue_from Errors::NoTokenExistsError, with: :no_token_exists
    rescue_from Errors::ServiceProviderNotFoundError, with: :service_provider_not_found

    def index
      # from = Time.new(2015, 8, 3).in_time_zone.beginning_of_day
      # to = Time.new(2015, 9, 1).in_time_zone.beginning_of_day
      # session = Sessions::TokenAuthorizedSession.new(current_user.google_tokens.first.token, GoogleToken.base_uri)
      # session = Sessions::TokenAuthorizedSession.new(current_user.fitbit_tokens.first.token, FitbitToken.base_uri)
      # render json: DataServices::GoogleService.new(session).steps(from, to) and return
      # render json: DataServices::GoogleService.new(session).sleep(20.days.ago.beginning_of_day.in_time_zone,
      # Time.zone.now) and return
      # render json: DataServices::GoogleService.new(session).sources and return
      # render json: DataServices::GoogleService.new(session).calories(from, to) and return
      # render json: DataServices::FitbitService.new(session).calories(from, to) and return
      # last_measurement_time = Time.now.change(hour: 22, min: 00)
      # measurements_per_day = 3
      # interval = 6
      # service = DataServices::FitbitService.new(current_user.fitbit_tokens.first)
      # render json: service.heart_rate(from, to) and return
      # render json: DataServices::SummarizedDataService.new(service,
      # last_measurement_time, measurements_per_day, interval, false).steps(from, to) and return

      first_measurement = Time.new(2015, 8, 3, 10, 00).in_time_zone
      number_of_days = 30
      respond_to do |format|
        format.html { @values = Exporters::JsonExporter.new.export(current_user, first_measurement, number_of_days) }
        format.json { render json: Exporters::JsonExporter.new.export(current_user, first_measurement, number_of_days) }
        format.csv { render text: Exporters::CsvExporter.new.export(current_user, first_measurement, number_of_days) }
        format.raw { render json: Exporters::RawExporter.new.export(current_user, first_measurement, number_of_days,
                                                                    params[:state], params[:data_source]) }
      end
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

    private

    def current_user
      return @current_user if @current_user
      if params[:email] && check_email(params[:email]) && User.find_by_email(params[:email]).id != session['user_id']
        session.delete('user_id')
      end
      if session['user_id']
        @current_user ||= User.find(session['user_id'])
      else
        check_email(params[:email])
        @current_user ||= User.find_by_email(params[:email])
        session['user_id'] = @current_user.id
      end
      @current_user
    end

    def check_email(email)
      fail Errors::EmailNotFoundError unless User.find_by_email(email)
      true
    end

    def email_not_found
      render status: 404, plain: 'ERROR: No user exists for the specified email ' \
                                 'address (or no email address was specified).'
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
      my_tokens = provider_tokens(params[:state])

      if my_tokens.blank? || !my_tokens.first.complete?
        redirect_to authorize_oauth_session_index_path(provider: params[:state])
      else
        # Refresh all tokens here?
        current_user.physiqual_tokens.each { |token| token.refresh! if token.expired? && token.complete? }
      end
    end

    def find_or_create_token
      tokens = provider_tokens params[:provider]
      @token = get_or_create_token(tokens)
    end

    def find_token
      tokens = provider_tokens params[:provider]
      fail Errors::NoTokenExistsError if tokens.blank?
      @token = tokens.first
    end

    def provider_tokens(provider)
      tokens = nil
      if provider == GoogleToken.csrf_token
        tokens = current_user.google_tokens
      elsif provider == FitbitToken.csrf_token
        tokens = current_user.fitbit_tokens
      else
        fail Errors::ServiceProviderNotFoundError
      end
      tokens
    end

    def get_or_create_token(tokens)
      return tokens.first unless tokens.blank?
      tokens.create
    end

    def sanitize_params
      token_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      params[:provider] = token_options.include?(params[:provider]) ? params[:provider] : nil
    end

    def sanitize_export_params
      service_provider_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      params[:state] = service_provider_options.include?(params[:state]) ? params[:state] : nil
      data_source_options = ['heart_rate', 'calories', 'steps', 'activities', 'sleep']
      params[:data_source] = data_source_options.include?(params[:data_source]) ? params[:data_source] : nil
    end
  end
end
