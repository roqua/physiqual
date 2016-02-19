module Physiqual
  class TestLoginController < ApplicationController
    before_filter :check_environment

    def create
      session['physiqual_user_id'] = sessions_params[:session_id]
      render :index
    end

    def index
      @sources = 'No google token'
      return unless session['physiqual_user_id'] && User.find_by_user_id(user_session)
      user = User.find_by_user_id(user_session)
      tok = Token.find_provider_token(GoogleToken.csrf_token, user)
      return unless tok && tok.complete?
      session = Sessions::TokenAuthorizedSession.new(tok)
      bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(Physiqual.measurements_per_day,
                                                                          Physiqual.interval,
                                                                          Physiqual.hours_before_first_measurement
                                                                         )
      service = DataServices::SummarizedDataService.new DataServices::FitbitService.new(session), bucket_generator

      # @sources = service.sources.to_yaml
      @sources = service.steps(2.days.ago.in_time_zone, Time.zone.now)
    end

    private

    def check_environment
      raise 'Environment not development!!!' unless Rails.env.development?
    end

    def sessions_params
      params.permit(:session_id)
    end
  end
end
