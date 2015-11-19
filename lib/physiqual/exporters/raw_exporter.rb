module Physiqual
  module Exporters
    class RawExporter < Exporter
      def configure(provider, data_source)
        provider = provider
        @data_source = data_source
        self
      end

      def export_data(user_id, first_measurement, number_of_days)
        user = User.find_by_user_id(user_id)
        token = Token.provider_token(@provider, user)
        return [] unless token && token.complete?
        session = Sessions::TokenAuthorizedSession.new(token)
        service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
        from, to = determine_time_span(first_measurement, number_of_days)
        service.send(@data_source.to_sym, from, to)
      end

      def export(user, first_measurement, number_of_days)
        export_data(user, first_measurement, number_of_days).to_json
      end

      private

      def determine_time_span(first_measurement, number_of_days)
        from = first_measurement - Physiqual.hours_before_first_measurement.hours
        to = first_measurement + (number_of_days - 1).days +
             ((Physiqual.measurements_per_day - 1) * Physiqual.interval).hours
        [from, to]
      end
    end
  end
end
