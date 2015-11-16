module Physiqual
  class ExportController < ApplicationController
    include SessionsHelper

    before_filter :sanitize_export_params, only: [:index]

    before_filter :check_token, only: :index

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

      respond_to_formats(export_params[:first_measurement],
                         export_params[:number_of_days])
      # render json: FitbitService.new(current_user.fitbit_tokens.first).steps(from, to)
      # render json: FitbitService.new(current_user.fitbit_tokens.first).heart_rate(from, to)
    end

    def export_params
      params.permit(:first_measurement, :number_of_days)
    end
  end
end