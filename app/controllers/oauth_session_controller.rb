require 'oauth2'
class OauthSessionController < ApplicationController
  http_basic_authenticate_with name: 'test', password: 'framando', only: :index

  before_filter :sanitize_params, only: [:authorize, :callback]

  before_filter :check_token, only: :index
  before_filter :set_token, only: :authorize
  before_filter :token, only: :callback

  def index
    last_measurement_time = Time.now.change(hour: 22, min: 30)
    interval = 1
    measurements_per_day = 23
    google_service = GoogleService.new(current_user.google_tokens.first)
    google_service = CachedDataService.new SummarizedDataService.new(google_service,
                                                                     last_measurement_time,
                                                                     measurements_per_day,
                                                                     interval,
                                                                     false)

    fitbit_service = FitbitService.new(current_user.fitbit_tokens.first)
    fitbit_service = CachedDataService.new SummarizedDataService.new(fitbit_service,
                                                                     last_measurement_time,
                                                                     measurements_per_day,
                                                                     interval,
                                                                     false)

    data_aggregator = DataAggregator.new([google_service, fitbit_service])

    from = 30.days.ago.in_time_zone.beginning_of_day
    to = 1.days.ago.in_time_zone.end_of_day

    # if params[:state] == 'google'
    # json = @google_service.steps(from, to)
    # elsif params[:state] == 'fitbit'
    # json = fitbit_service.steps(from,to)
    # json = @fitbit_service.sleep(from, to)
    # end
    render json: data_aggregator.steps(from, to)
    # render json: json
    # results = @google_service.steps(10.days.ago, Time.now, 1.hour)

    # @categories = results.keys.to_json
    # @values = results.values
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
    my_tokens = current_user.tokens.select { |x| x.class.csrf_token == params[:state] }
    if my_tokens.blank? || my_tokens.first.token.blank?
      redirect_to authorize_oauth_session_index_path(provider: params[:state])
    else
      @token = my_tokens.first
      @token.refresh!  if @token.expired?
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
    @token = current_user.tokens.select { |x| x.class.csrf_token == params[:provider] }
    head 404 if @token.blank?
    @token = @token.first
  end

  private

  def sanitize_params
    params[:provider] = %w(google fitbit).include?(params[:provider]) ? params[:provider] : nil
  end
end
