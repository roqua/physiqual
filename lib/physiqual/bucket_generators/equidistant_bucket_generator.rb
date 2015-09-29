module Physiqual
  module BucketGenerators
    class EquidistantBucketGenerator
      include BucketGenerator
      def initialize(measurements_per_day, interval, last_measurement_time)
        @measurements_per_day = measurements_per_day
        @interval = interval
        @last_measurement_time = last_measurement_time
      end
  
      def generate(from, to)
        from = from.beginning_of_day.to_datetime
        to = to.beginning_of_day.to_datetime
        result = []
        start = @last_measurement_time.hour - ((@measurements_per_day - 1) * @interval)
        from.to_date.upto(to.to_date).map do |date|
          (0...@measurements_per_day).map do |measurement|
            current = date.to_time.change(hour: start + (measurement * @interval),
                                          min: @last_measurement_time.min)
  
            # Only use dates that are in the past
            result << output_entry(current.to_time, []) if date < Time.zone.now
          end
        end
        result
      end
    end
  end
end
