module Physiqual
  class TestLoginController < ApplicationController
    before_filter :check_environment

    def create
      session['physiqual_user_id'] = sessions_params[:session_id]
      render :index
    end

    def index

    end

    def destroy

    end

    private

    def check_environment
      fail 'Environment not development!!!' unless Rails.env == 'development'
    end

    def sessions_params
      params.permit(:session_id)
    end
  end
end
