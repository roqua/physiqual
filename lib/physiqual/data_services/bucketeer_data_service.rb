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

      def current_bucket_is_the_correct_one?(current_bucket, entry, buckets)
        bucket_still_in_bucketlist = current_bucket < buckets.size
        entry_time_not_in_this_bucket = entry.measurement_moment > buckets[current_bucket].end_date
        !(bucket_still_in_bucketlist && entry_time_not_in_this_bucket)
      end

      def create_buckets(buckets, data)
        current_bucket = 0
        data.each do |entry|
          next unless entry.measurement_moment

          until current_bucket_is_the_correct_one?(current_bucket, entry, buckets)
            current_bucket += 1
          end

          break if current_bucket == buckets.size
          next unless entry.measurement_moment > buckets[current_bucket].start_date

          values = entry.values
          buckets[current_bucket].values.push(*values)
        end
      end
    end
  end
end
