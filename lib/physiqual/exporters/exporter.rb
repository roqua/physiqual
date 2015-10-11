module Physiqual
  module Exporters
    class Exporter
      def export_data(user, first_measurement, number_of_days)
        services = create_services(user.physiqual_tokens)
        data_aggregator = DataAggregator.new(services, Physiqual.imputers)

        from = first_measurement - Physiqual.hours_before_first_measurement.hours
        to   = first_measurement + (number_of_days - 1).days +
          ((Physiqual.measurements_per_day - 1) * Physiqual.interval).hours

        activities = data_aggregator.activities(from, to)
        heart_rate = data_aggregator.heart_rate(from, to)
        steps = data_aggregator.steps(from, to)
        calories = data_aggregator.calories(from, to)
        distance = data_aggregator.distance(from, to)

        result = {}
        # TODO: Waarom index je dit op de dates steps en itereer je niet gewoon over alle dates?
        steps.keys.each do |date|
          result[date] = {}
          result[date][:heart_rate] = heart_rate[date]
          result[date][:steps] = steps[date]
          # result[date][:sleep] = steps[date]
          result[date][:calories] = calories[date]
          result[date][:activities] = activities[date]
          result[date][:distance] = distance[date]
        end
        result
      end

      private

      def create_services(tokens)
        tokens.map do |token|
          next unless token.complete?
          session = Sessions::TokenAuthorizedSession.new(token.token, token.class.base_uri)
          service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
          service = DataServices::SummarizedDataService.new(service,
                                                            Physiqual.measurements_per_day,
                                                            Physiqual.interval,
                                                            Physiqual.hours_before_first_measurement)

          DataServices::CachedDataService.new service
        end.compact
      end
    end
  end
end
