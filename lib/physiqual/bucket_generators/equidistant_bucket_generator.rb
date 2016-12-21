module Physiqual
  module BucketGenerators
    class EquidistantBucketGenerator
      include BucketGenerator
      def initialize(measurements_per_day, interval, hours_before_first_measurement)
        @measurements_per_day = measurements_per_day
        @interval = interval
        @hours_before_first_measurement = hours_before_first_measurement
      end

      def generate(from, to)
        currently = Time.zone.now
        first_measurement_of_the_day = from
        bucket_start = -1
        bucket_end = -1
        result = []
        loop do
          @measurements_per_day.times do |measurement_index|
            if measurement_index.zero?
              bucket_start = first_measurement_of_the_day
              bucket_end   = bucket_start + @hours_before_first_measurement.hours
            else
              bucket_start = bucket_end
              bucket_end   = bucket_start + @interval.hours
            end

            # CEST and CET fix
            bucket_end += bucket_start.utc_offset - bucket_end.utc_offset
            return result if bucket_end > to || bucket_end >= currently
            result << DataEntry.new(start_date: bucket_start,
                                    end_date: bucket_end,
                                    measurement_moment: bucket_end)
          end
          first_measurement_of_the_day += 1.day
        end
        result
      end
    end
  end
end
