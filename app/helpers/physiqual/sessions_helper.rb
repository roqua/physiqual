module Physiqual
  module SessionsHelper
    def respond_to_formats(first_measurement, number_of_days)

      respond_to do |format|
        format.html { @values = Exporters::JsonExporter.new.export(current_user.user_id, first_measurement, number_of_days) }
        format.json { render json: Exporters::JsonExporter.new.export(current_user.user_id, first_measurement, number_of_days) }
        format.csv { render text: Exporters::CsvExporter.new.export(current_user.user_id, first_measurement, number_of_days) }
        format.raw { render_raw(first_measurement, number_of_days) }
      end
    end

    def render_raw(first_measurement, number_of_days)
      render json: Exporters::RawExporter
        .new
        .configure(params[:state], params[:data_source])
        .export(current_user.user_id, first_measurement, number_of_days)
    end

    def current_user
      @current_user ||= User.find_by_user_id(session['physiqual_user_id'])
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
      token = Token.provider_token(params[:state], current_user)

      if token.nil? || !token.complete?
        redirect_to authorize_oauth_session_index_path(provider: params[:state])
      end
    end

    def find_token
      @token = Token.provider_token params[:provider], current_user
      fail Errors::NoTokenExistsError if @token.nil?
    end

    def sanitize_export_params
      service_provider_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      params[:state] = service_provider_options.include?(params[:state]) ? params[:state] : nil
      data_source_options = %w(heart_rate calories steps activities sleep)
      params[:data_source] = data_source_options.include?(params[:data_source]) ? params[:data_source] : nil
    end
  end
end
