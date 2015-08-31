module Exporters
  class Exporter
    def export_me(user, last_measurement_time, from, to)
      interval = 6
      measurements_per_day = 3

      services = user.tokens.map do |token|
        service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, token)
        service = DataServices::SummarizedDataService.new(service, last_measurement_time, measurements_per_day, interval, false)
        DataServices::CachedDataService.new service
      end.compact

      data_aggregator = DataAggregator.new(services, [Imputers::CatMullImputer.new])
      #activities = data_aggregator.activities(from, to)
      heart_rate = data_aggregator.heart_rate(from, to)
      #Rails.logger.debug activities
      #steps = data_aggregator.steps(from, to)
      result = {}
      heart_rate.keys.each do |date|
        result[date] = {}
        result[date][:heart_rate] = heart_rate[date]
        #result[date][:steps] = steps[date]
        #result[date][:sleep] = steps[date]
        #result[date][:calories] = steps[date]
        #result[date][:activities] = activities[date]
      end
      result
    end
  end
end
