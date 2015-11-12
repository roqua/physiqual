module Physiqual
  module Exporters
    class RawExporter < Exporter
      def configure(service_provider, data_source)
        @service_provider = service_provider
        @data_source = data_source
        self
      end

      def export_data(user, first_measurement, number_of_days)
        tokens = Token.provider_tokens(@service_provider, user)
        return [] unless !tokens.blank? && tokens.first.complete?
        token = tokens.first
        session = Sessions::TokenAuthorizedSession.new(token.token, token.class.base_uri)
        service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
        from, to = determine_time_span(first_measurement, number_of_days)
        service.send(@data_source.to_sym, from, to)
      end

      def export(user, first_measurement, number_of_days)
        result = export_data(user, first_measurement, number_of_days)
        result.to_json
      end

      private

      def determine_time_span
        from = first_measurement - Physiqual.hours_before_first_measurement.hours
        to = first_measurement + (number_of_days - 1).days +
             ((Physiqual.measurements_per_day - 1) * Physiqual.interval).hours
        [from, to]
      end
    end
  end
end
