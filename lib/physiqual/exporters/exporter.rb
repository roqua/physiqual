module Physiqual
  module Exporters
    class Exporter
      def export_data(user_id, first_measurement, number_of_days)
        user = User.find_by_user_id(user_id)
        bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(
          Physiqual.measurements_per_day,
          Physiqual.interval,
          Physiqual.hours_before_first_measurement)

        service = create_service(user.physiqual_token, bucket_generator)
        data_imputer = DataImputer.new(service, Physiqual.imputers)

        from = from_time(first_measurement)
        to = to_time(first_measurement, number_of_days)

        buckets = bucket_generator.generate(from, to)
        aggregate_data_into_buckets(from, to, data_imputer, buckets)
      end

      private

      def from_time(first_measurement)
        first_measurement - Physiqual.hours_before_first_measurement.hours
      end

      def to_time(first_measurement, number_of_days)
        first_measurement + (number_of_days - 1).days +
          ((Physiqual.measurements_per_day - 1) * Physiqual.interval).hours
      end

      def create_service(token, bucket_generator)
        return [] unless token.complete?
        session = Sessions::TokenAuthorizedSession.new(token)
        service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
        service = DataServices::BucketeerDataService.new(service, bucket_generator)
        service = DataServices::SummarizedDataService.new(service)
        DataServices::CachedDataService.new service
      end

      def aggregate_data_into_buckets(from, to, data_imputer, buckets)
        result = {}
        [:activities, :heart_rate, :steps, :calories, :distance].each do |meth|
          data = data_imputer.send(meth, from, to)
          buckets.each do |bucket|
            date = bucket.end_date
            result[date] = {} if result[date].nil?
            result[date][meth] = data[date]
          end
        end
        result
      end
    end
  end
end
