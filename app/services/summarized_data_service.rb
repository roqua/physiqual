class SummarizedDataService < DataServiceDecorator
  def initialize(data_service, last_measurement_time, measurements_per_day, interval, use_night)
    super(data_service)
    @last_measurement_time = last_measurement_time
    @measurements_per_day = measurements_per_day
    @interval = interval
    @use_night = use_night
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
    calories = data_service.calories(from, to)
    cluster_in_buckets(calories, from, to)
  end

  def steps(from, to)
    steps = data_service.steps(from, to)
    cluster_in_buckets(steps, from, to)
  end

  private

  def cluster_in_buckets(data, from, to)
    buckets = generate_buckets(from, to)
    current_bucket = 0

    data[key].each do |entry|
      next unless entry[date_time]

      while current_bucket < buckets.size && entry[date_time] > buckets.keys[current_bucket]
        current_bucket += 1
      end

      break if current_bucket == buckets.size

      # Don't take the night into account
      next unless entry[date_time] >= (buckets.keys[current_bucket] - @interval.hours) || @use_night

      buckets[buckets.keys[current_bucket]] += entry['value'].to_i
    end
    buckets
  end

  def generate_buckets(from, to)
    from = from.beginning_of_day.to_datetime
    to = to.beginning_of_day.to_datetime

    Hash[(from..to).flat_map do |date|
      (0...@measurements_per_day).map do |measurement|
        date = date.change(hour: @last_measurement_time.hour - (measurement * @interval),
                           min: @last_measurement_time.min)

        # Only use dates that are in the past
        [date, 0] if date < Time.zone.now
      end.compact.reverse
    end]
  end
end
