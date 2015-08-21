class SummarizedDataService < DataServiceDecorator
 def initialize(data_service, last_measurement_time, measurements_per_day, interval, use_night)
   super(data_service)
   @last_measurement_time = last_measurement_time
   @measurements_per_day = measurements_per_day
 end

  def get_steps(from, to)
    buckets = generate_buckets(from, to, last_measurement_time, measurements_per_day, interval)

    current_bucket = 0
    steps = data_service.get_steps(from, to)

    steps['activities-steps'].each do |entry|
      current_time_step = entry['dateTime']
      next if current_time_step.nil?

      while current_bucket < buckets.size && current_time_step > buckets.keys[current_bucket]
        current_bucket += 1
      end

      break if current_bucket == buckets.size

      # Don't take the night into account
      if current_time_step >= (buckets.keys[current_bucket] - interval.hours) || use_night
        value = entry['value'].to_i
        buckets[buckets.keys[current_bucket]] += value
      end
    end
    buckets
  end

  private

  def generate_buckets(from, to, last_measurement_time, measurements_per_day, measurement_period)
    from = from.beginning_of_day.to_datetime
    to = to.beginning_of_day.to_datetime
    Hash[(from..to).flat_map do |date|
      (0...measurements_per_day).map do |measurement|
        date = date.change(hour: last_measurement_time.hour - (measurement * measurement_period), min: last_measurement_time.min)

        # Only use dates that are in the past
        [date, 0] if date < Time.zone.now
      end.compact.reverse
    end]
  end


end
