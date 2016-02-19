module Physiqual
  module ExportsHelper
    def assert_service_provider
      provider_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      raise Errors::ServiceProviderNotFoundError unless provider_options.include?(params[:provider])
    end

    def assert_data_source
      data_source_options = %w(heart_rate calories steps activities sleep)

      raise(Errors::InvalidParamsError, 'data source') unless data_source_options.include?(params[:data_source])
    end

    def assert_first_measurement
      raise(Errors::InvalidParamsError, 'first measurement missing') unless params[:first_measurement]
      m = /^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2})/.match(params[:first_measurement])
      raise(Errors::InvalidParamsError, 'incorrect format of first measurement') unless m
      params[:first_measurement] = Time.new(m[1], m[2], m[3], m[4], m[5]).in_time_zone
    end

    def assert_number_of_days
      raise(Errors::InvalidParamsError, 'number of days is missing') unless params[:number_of_days]
      number_of_days = params[:number_of_days].to_i.to_s
      raise(Errors::InvalidParamsError, 'number of days not integer') unless params[:number_of_days] == number_of_days
      params[:number_of_days] = params[:number_of_days].to_i
    end
  end
end
