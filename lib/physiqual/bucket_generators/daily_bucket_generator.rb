module Physiqual
  module BucketGenerators
    class DailyBucketGenerator
      include BucketGenerator
      def initialize(measurement_moments, hours_before_first_measurement)
        @measurement_moments = measurement_moments
        @hours_before_first_measurement = hours_before_first_measurement
      end

      def generate(from, to)
        from = from.beginning_of_day.to_datetime
        to = to.beginning_of_day.to_datetime
        result = []
        from.to_date.upto(to.to_date).each do |date|
          bucket_end = -1
          @measurement_moments.each_with_index do |measurement, measurement_index|
            bucket_start = bucket_end
            bucket_end = date.to_time.change(hour: measurement.hour,
                                             min: measurement.min).in_time_zone
            bucket_start = bucket_end - @hours_before_first_measurement.hours if measurement_index == 0

            # Only use dates that are in the past
            result << output_entry(bucket_start, bucket_end, []) if bucket_end < Time.zone.now
          end
        end
        result
      end
    end
  end
end
