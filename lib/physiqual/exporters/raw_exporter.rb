module Physiqual
  module Exporters
    class RawExporter < Exporter
      def export_data(user, first_measurement, number_of_days)
        tokens = []
        if @service_provider == GoogleToken.csrf_token
          tokens = user.google_tokens
        elsif @service_provider == FitbitToken.csrf_token
          tokens = user.fitbit_tokens
        end
        return [] unless !tokens.blank? && tokens.first.complete?
        token = tokens.first
        session = Sessions::TokenAuthorizedSession.new(token.token, token.class.base_uri)
        service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)

        from = first_measurement - Physiqual.hours_before_first_measurement.hours
        to   = first_measurement + (number_of_days - 1).days +
               ((Physiqual.measurements_per_day - 1) * Physiqual.interval).hours

        service.send(@data_source.to_sym, from, to)
      end

      def export(user, first_measurement, number_of_days, service_provider, data_source)
        @service_provider = service_provider
        @data_source = data_source
        result = export_data(user, first_measurement, number_of_days)
        result.to_json
      end
    end
  end
end
