module Physiqual
  module OauthSessionHelper
    def respond_to_formats(first_measurement, number_of_days)
      respond_to do |format|
        format.html { @values = Exporters::JsonExporter.new.export(current_user, first_measurement, number_of_days) }
        format.json { render json: Exporters::JsonExporter.new.export(current_user, first_measurement, number_of_days) }
        format.csv { render text: Exporters::CsvExporter.new.export(current_user, first_measurement, number_of_days) }
        format.raw { render_raw(first_measurement, number_of_days) }
      end
    end

    def render_raw(first_measurement, number_of_days)
      render json: Exporters::RawExporter
        .new
        .configure(params[:state], params[:data_source])
        .export(current_user, first_measurement, number_of_days)
    end

    def current_user
      return @current_user if @current_user
      resolve_session_conflicts(params[:email])
      if session['user_id']
        @current_user ||= User.find(session['user_id'])
      else
        check_email(params[:email])
        @current_user ||= User.find_by_email(params[:email])
        session['user_id'] = @current_user.id
      end
      @current_user
    end

    def resolve_session_conflicts(email)
      session.delete('user_id') if email && check_email(email) && User.find_by_email(email).id != session['user_id']
    end

    def check_email(email)
      fail Errors::EmailNotFoundError unless User.find_by_email(email)
      true
    end

    def email_not_found
      render status: 404, plain: 'ERROR: No user exists for the specified email ' \
                                 'address (or no email address was specified).'
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
      my_tokens = Token.provider_tokens(params[:state], current_user)

      if my_tokens.blank? || !my_tokens.first.complete?
        redirect_to authorize_oauth_session_index_path(provider: params[:state])
      else
        # Refresh all tokens here?
        current_user.physiqual_tokens.each { |token| token.refresh! if token.expired? && token.complete? }
      end
    end

    def find_or_create_token
      tokens = Token.provider_tokens params[:provider], current_user
      @token = get_or_create_token(tokens)
    end

    def find_token
      tokens = Token.provider_tokens params[:provider], current_user
      fail Errors::NoTokenExistsError if tokens.blank?
      @token = tokens.first
    end

    def get_or_create_token(tokens)
      return tokens.first unless tokens.blank?
      tokens.create
    end

    def sanitize_params
      token_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      params[:provider] = token_options.include?(params[:provider]) ? params[:provider] : nil
    end

    def sanitize_export_params
      service_provider_options = [GoogleToken.csrf_token, FitbitToken.csrf_token]
      params[:state] = service_provider_options.include?(params[:state]) ? params[:state] : nil
      data_source_options = %w(heart_rate calories steps activities sleep)
      params[:data_source] = data_source_options.include?(params[:data_source]) ? params[:data_source] : nil
    end
  end
end
