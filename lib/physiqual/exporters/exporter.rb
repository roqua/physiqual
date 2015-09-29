module Physiqual
  module Exporters
    class Exporter
      def export_data(user, last_measurement_time, from, to)
        # TODO: These variables below should be configurable (how?)
        interval = 6
        measurements_per_day = 3
  
        services = create_services(user.tokens, last_measurement_time, interval, measurements_per_day)
        # TODO: Should the set of imputers used be configurable too?
        data_aggregator = DataAggregator.new(services, [Imputers::CatMullImputer])
        activities = data_aggregator.activities(from, to)
        heart_rate = data_aggregator.heart_rate(from, to)
        steps = data_aggregator.steps(from, to)
        calories = data_aggregator.calories(from, to)
        result = {}
        steps.keys.each do |date|
          result[date] = {}
          result[date][:heart_rate] = heart_rate[date]
          result[date][:steps] = steps[date]
          # result[date][:sleep] = steps[date]
          result[date][:calories] = calories[date]
          result[date][:activities] = activities[date]
        end
        result
      end
  
      private
  
      def create_services(tokens, last_measurement_time, interval, measurements_per_day)
        tokens.map do |token|
          next unless token.complete?
          session = Sessions::TokenAuthorizedSession.new(token.token, token.class.base_uri)
          service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
          service = DataServices::SummarizedDataService.new(service,
                                                            last_measurement_time,
                                                            measurements_per_day,
                                                            interval, true)
          # TODO: This use_night thing above should be configurable.
          DataServices::CachedDataService.new service
        end.compact
      end
    end
  end
end