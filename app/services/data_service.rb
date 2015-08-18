class DataService

  DATE_FORMAT = '%Y-%m-%d'

  def get_steps(from, to)
  end

  def get_steps_in_blocks(from, to, last_measurement_time, measurements_per_day, interval, use_night)
    buckets = generate_buckets(from, to, last_measurement_time, measurements_per_day, interval)

    current_bucket = 0
    steps = get_steps(from, to)

    steps['activities-steps'].each do |entry|
      current_time_step = entry['dateTime']
      next if current_time_step.nil?

      while current_bucket < buckets.size && current_time_step > buckets.keys[current_bucket] do
        current_bucket+=1
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
    Hash[(from..to).map do |date|
      (0...measurements_per_day).map do |measurement|
        date = date.change(hour: last_measurement_time.hour - (measurement * measurement_period), min: last_measurement_time.min)

        # Only use dates that are in the past
        [date, 0] if date < Time.zone.now
      end.compact.reverse
    end.flatten(1)]
  end
end
