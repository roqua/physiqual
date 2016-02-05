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
      service = DataServices::GoogleService.new(session)
      @sources = service.sources.to_yaml
    end

    private

    def check_environment
      fail 'Environment not development!!!' unless Rails.env.development?
    end

    def sessions_params
      params.permit(:session_id)
    end
  end
end
