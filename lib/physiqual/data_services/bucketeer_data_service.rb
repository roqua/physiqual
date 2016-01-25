module Physiqual
  module DataServices
    class BucketeerDataService < DataServiceDecorator
      def initialize(data_service, bucket_generator)
        super(data_service)
        @bucket_generator = bucket_generator
      end

      def service_name
        "bucketeer_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        heart_rate = data_service.heart_rate(from, to)
        cluster_in_buckets(heart_rate, from, to)
      end

      def sleep(from, to)
        sleep = data_service.sleep(from, to)
        cluster_in_buckets(sleep, from, to)
      end

      def calories(from, to)
        calories_measured = data_service.calories(from, to)
        cluster_in_buckets(calories_measured, from, to)
      end

      def distance(from, to)
        distance = data_service.distance(from, to)
        cluster_in_buckets(distance, from, to)
      end

      def steps(from, to)
        steps = data_service.steps(from, to)
        cluster_in_buckets(steps, from, to)
      end

      def activities(from, to)
        activities = data_service.activities(from, to)
        cluster_in_buckets(activities, from, to)
      end

      private

      def cluster_in_buckets(data, from, to)
        buckets = @bucket_generator.generate(from, to)
        current_bucket = 0

        # Sort data array
        data.sort_by! { |entry| entry.measurement_moment }

        data.each do |entry|
          next unless entry.measurement_moment

          while current_bucket < buckets.size && entry[date_time_field] > buckets[current_bucket].measurement_moment
            current_bucket += 1
          end

          break if current_bucket == buckets.size

          unless entry.measurement_moment > buckets[current_bucket].start_date
            next
          end
          values = entry.values
          buckets[current_bucket].values.push(*values)
        end

        buckets
      end
    end
  end
end
