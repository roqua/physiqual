require 'oauth2'
module Physiqual
  class OauthSessionController < ApplicationController
    before_filter :sanitize_params, only: [:authorize, :callback]

    before_filter :check_token, only: :index
    before_filter :set_token, only: :authorize
    before_filter :token, only: :callback

    def index
      frank = true
      if frank
        from = Time.new(2015, 8, 3).in_time_zone.beginning_of_day
        to = Time.new(2015, 9, 1).in_time_zone.beginning_of_day
      else
        from = Time.new(2015, 7, 15).in_time_zone.beginning_of_day
        to = Time.new(2015, 7, 17).in_time_zone.end_of_day
      end
      # session = Sessions::TokenAuthorizedSession.new(current_user.google_tokens.first.token, GoogleToken.base_uri)
      # session = Sessions::TokenAuthorizedSession.new(current_user.fitbit_tokens.first.token, FitbitToken.base_uri)
      # render json: DataServices::GoogleService.new(session).steps(from, to) and return
      # render json: DataServices::GoogleService.new(session).distance(from, to) and return
      # render json: DataServices::GoogleService.new(session).sleep(20.days.ago.beginning_of_day.in_time_zone,
      # Time.zone.now) and return
      # render json: DataServices::GoogleService.new(session).sources and return
      # render json: DataServices::GoogleService.new(session).calories(from, to) and return
      # render json: DataServices::FitbitService.new(session).calories(from, to) and return
      last_measurement_time = Time.now.change(hour: 22, min: 00)
      # measurements_per_day = 3
      # interval = 6
      # service = DataServices::FitbitService.new(current_user.fitbit_tokens.first)
      # render json: service.heart_rate(from, to) and return
      # render json: DataServices::SummarizedDataService.new(service,
      # last_measurement_time, measurements_per_day, interval, false).steps(from, to) and return
      respond_to do |format|
        format.html { @values = Exporters::JsonExporter.new.export(current_user, last_measurement_time, from, to) }
        format.json { render json: Exporters::JsonExporter.new.export(current_user, last_measurement_time, from, to) }
        format.csv { render text: Exporters::CsvExporter.new.export(current_user, last_measurement_time, from, to) }
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
      if params[:email] && User.find_by_email(params[:email]).id != session['user_id']
        session.delete('user_id')
      end
      if session['user_id']
        @current_user ||= User.find(session['user_id'])
      else
        @current_user ||= User.find_by_email(params[:email])
        session['user_id'] = @current_user.id
      end
      @current_user
    end

    def check_token
      # my_tokens = current_user.physiqual_tokens
      my_tokens = provider_tokens(params[:state])

      if my_tokens.blank? || !my_tokens.first.complete?
        redirect_to authorize_oauth_session_index_path(provider: params[:state])
      else
        # Refresh all tokens here?
        current_user.physiqual_tokens.each { |token| token.refresh! if token.expired? && token.complete? }
      end
    end

    def set_token
      tokens = provider_tokens params[:provider]
      head 404 and return if tokens.nil?
      @token = get_or_create_token(tokens)
    end

    def token
      @token = current_user.physiqual_tokens.select { |x| x.class.csrf_token == params[:provider] }
      head 404 if @token.blank?

      # @token should always have length == 1
      @token = @token.first
    end

    def provider_tokens(provider)
      tokens = nil
      if provider == GoogleToken.csrf_token
        tokens = current_user.google_tokens
      elsif provider == FitbitToken.csrf_token
        tokens = current_user.fitbit_tokens
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
  end
end
