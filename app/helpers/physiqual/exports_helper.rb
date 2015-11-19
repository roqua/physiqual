module Physiqual
  module ExportsHelper
    def assert_service_provider
      service_provider_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      fail Errors::ServiceProviderNotFoundError unless service_provider_options.include?(raw_params[:provider])
    end

    def assert_data_source
      data_source_options = %w(heart_rate calories steps activities sleep)
      fail(Errors::InvalidParamsError) unless data_source_options.include?(raw_params[:data_source])
    end

    def assert_first_measurement
      fail(Errors::InvalidParamsError) unless params[:first_measurement]

      Time.new(2015, 8, 3, 10, 00).in_time_zone
      m = %r(^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2})).match(params[:first_measurement])
      fail(Errors::InvalidParamsError) unless m
      params[:first_measurement] = Time.new(m[1], m[2], m[3], m[4], m[5])
    end

    def assert_number_of_days
      fail(Errors::InvalidParamsError) unless params[:number_of_days]
      params[:number_of_days] = params[:number_of_days].to_i
    end

    def invalid_params
      render status: 404, plain: 'ERROR: The provided params are incorrect or not specified'
    end
  end
end