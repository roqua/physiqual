module Physiqual
  module Exporters
    class Exporter
      def export_data(user_id, first_measurement, number_of_days, provider = 'all')
        user = User.find_by_user_id(user_id)
        bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(
          Physiqual.measurements_per_day,
          Physiqual.interval,
          Physiqual.hours_before_first_measurement)

        tokens = nil

        if(provider == 'all')
          tokens = user.physiqual_tokens
        else
          tokens = [Token.provider_token(provider, user)]
        end

        services = create_services(tokens, bucket_generator)
        data_aggregator = DataAggregator.new(services, Physiqual.imputers)

        from = from_time(first_measurement)
        to = to_time(first_measurement, number_of_days)

        buckets = bucket_generator.generate(from, to)
        aggregate_data_into_buckets(from, to, data_aggregator, buckets)
      end

      private

      def from_time(first_measurement)
        first_measurement - Physiqual.hours_before_first_measurement.hours
      end

      def to_time(first_measurement, number_of_days)
        first_measurement + (number_of_days - 1).days +
          ((Physiqual.measurements_per_day - 1) * Physiqual.interval).hours
      end

      def create_services(tokens, bucket_generator)
        tokens.map do |token|
          next unless token.complete?
          session = Sessions::TokenAuthorizedSession.new(token)
          service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
          service = DataServices::SummarizedDataService.new(service, bucket_generator)
          DataServices::CachedDataService.new service
        end.compact
      end

      def aggregate_data_into_buckets(from, to, data_aggregator, buckets)
        activities = data_aggregator.activities(from, to)
        heart_rate = data_aggregator.heart_rate(from, to)
        steps = data_aggregator.steps(from, to)
        calories = data_aggregator.calories(from, to)
        distance = data_aggregator.distance(from, to)

        result = {}
        buckets.each do |bucket|
          date = bucket[DataServices::DataService::DATE_TIME_FIELD]
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
    end
  end
end
