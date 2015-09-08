module BucketGenerators
  class DailyBucketGenerator
    include BucketGenerator 
    def initialize(measurement_moments)
      @measurement_moments = measurement_moments
    end

    def generate(from, to)
      from = from.beginning_of_day.to_datetime
      to = to.beginning_of_day.to_datetime
      result = []
      from.to_date.upto(to.to_date).each_with_index do |date|
        @measurement_moments.each do |measurement|
          current = date.to_time.change(hour: measurement.hour,
                                        min: measurement.min)

          # Only use dates that are in the past
          result << output_entry(current.to_time, []) if date < Time.zone.now
        end
      end
      result
    end
  end
end
