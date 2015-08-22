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
    offset = 0
    max = 300
    k = 2
    soft_histogram(cluster_in_buckets(heart_rate, from, to), offset, max, k)
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
    sum_values(cluster_in_buckets(steps, from, to))
  end

  private

  def sum_values(data)
    Hash[data.keys.map { |key| [key, data[key].sum] }]
  end

  def soft_histogram(data, min, max, k)
    Hash[data.keys.map do |key|
      histogram = Hash.new(0)
      data[key].each do |current|
        (current - k..current + k).each { |buck| histogram[buck] += 1 }
      end
      histogram.delete_if { |hist_key, _value| hist_key < min || hist_key > max }
      max_value = histogram.max.nil? ? nil : histogram.max_by { |_k, v| v }.first
      [key, max_value]
    end]
  end

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

      buckets[buckets.keys[current_bucket]] << entry['value'].to_i
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
        [date, []] if date < Time.zone.now
      end.compact.reverse
    end]
  end
end
