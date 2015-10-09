module Physiqual
  module Exporters
    class Exporter
      def export_data(user, last_measurement_time, from, to)
        services = create_services(user.physiqual_tokens, last_measurement_time)
        # TODO: Should the set of imputers used be configurable too?
        data_aggregator = DataAggregator.new(services, Physiqual.imputers)

        activities = data_aggregator.activities(from, to)
        heart_rate = data_aggregator.heart_rate(from, to)
        steps = data_aggregator.steps(from, to)
        calories = data_aggregator.calories(from, to)
        distance = data_aggregator.distance(from, to)

        result = {}
        heart_rate.keys.each do |date|
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

      def create_services(tokens, last_measurement_time)
        tokens.map do |token|
          next unless token.complete?
          session = Sessions::TokenAuthorizedSession.new(token.token, token.class.base_uri)
          service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
          service = DataServices::SummarizedDataService.new(service,
                                                            last_measurement_time,
                                                            Physiqual.measurements_per_day,
                                                            Physiqual.interval,
                                                            Physiqual.use_night)

          DataServices::CachedDataService.new service
        end.compact
      end
    end
  end
end
