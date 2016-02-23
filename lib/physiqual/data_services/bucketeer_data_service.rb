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
        data.sort_by!(&:measurement_moment)
        buckets = create_buckets(buckets, data)
        buckets
      end

      def create_buckets(buckets, data)
        current_bucket = 0
        data.each do |entry|
          next unless entry.measurement_moment

          while current_bucket_smaller_than_number_buckets?(current_bucket, buckets) &&
                entry_measurmenet_moment_outside_of_bucket?(current_bucket, entry, buckets)
            current_bucket += 1
          end

          # Note that the created buckets are in the interval (start_time, end-time]
          # (i.e., start_time < x <= end_time). This means startdates of two buckets
          # can be on the same data/ time, but a measurement on thtat exact moment will
          # always endup in the previous bucket.
          break if current_bucket == buckets.size
          next unless entry.measurement_moment > buckets[current_bucket].start_date

          values = entry.values
          buckets[current_bucket].values.push(*values)
        end
        buckets
      end

      def current_bucket_smaller_than_number_buckets?(current_bucket, buckets)
        current_bucket < buckets.size
      end

      def entry_measurmenet_moment_outside_of_bucket?(current_bucket, entry, buckets)
        entry.measurement_moment > buckets[current_bucket].end_date
      end
    end
  end
end
