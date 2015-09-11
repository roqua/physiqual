require 'oauth2'
class OauthSessionController < ApplicationController
  http_basic_authenticate_with name: 'test', password: 'framando', only: :index

  before_filter :sanitize_params, only: [:authorize, :callback]

  before_filter :check_token, only: :index
  before_filter :set_token, only: :authorize
  before_filter :token, only: :callback

  def index
    from = 60.days.ago.in_time_zone.beginning_of_day
    to = 1.days.ago.in_time_zone.end_of_day
    #    session = Sessions::TokenAuthorizedSession.new(current_user.fitbit_tokens.first.token, FitbitToken.base_uri)
    #   render json: DataServices::FitbitService.new(session).heart_rate(from, to) and return
    # render json: DataServices::GoogleService.new(session).sources and return
    # render json: DataServices::GoogleService.new(session).calories(from, to) and return
    last_measurement_time = Time.now.change(hour: 22, min: 30)
    # measurements_per_day = 3
    # interval = 6
    # service = DataServices::FitbitService.new(current_user.fitbit_tokens.first)
    # render json: service.heart_rate(from, to) and return
    # render json: DataServices::SummarizedDataService.new(service,
    # last_measurement_time, measurements_per_day, interval, false).steps(from, to) and return
    text = Exporters::CsvExporter.new.export(current_user, last_measurement_time, from, to)
    render json: text
    # render json: FitbitService.new(current_user.fitbit_tokens.first).steps(from, to)
    # render json: FitbitService.new(current_user.fitbit_tokens.first).heart_rate(from, to)
  end

  def authorize
    redirect_url = @token.class.build_authorize_url(callback_oauth_session_index_url(provider: @token.class.csrf_token))
    redirect_to redirect_url
  end

  def callback
    Rails.logger.info @token
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
    my_tokens = current_user.tokens
    provider_tokens = current_user.find_tokens(params[:provider])
    if my_tokens.blank? || my_tokens.first.token.blank? || provider_tokens
      redirect_to authorize_oauth_session_index_path(provider: params[:provider])
    else
      my_tokens.each { |token| token.refresh! if token.expired? && token.complete? }
      @token = my_tokens.first
    end
  end

  def set_token
    if params[:provider] == GoogleToken.csrf_token
      @token = current_user.google_tokens.create
    elsif params[:provider] == FitbitToken.csrf_token
      @token = current_user.fitbit_tokens.create
    else
      head 404
    end
  end

  def token
    @token = current_user.find_tokens params[:provider]
    head 404 if @token.blank?
    @token = @token.first
  end

  private

  def sanitize_params
    params[:provider] = %w(google fitbit).include?(params[:provider]) ? params[:provider] : nil
  end
end
