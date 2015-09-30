module Physiqual
  module DataServices
    class SummarizedDataService < DataServiceDecorator
      def initialize(data_service, last_measurement_time, measurements_per_day, interval, use_night)
        super(data_service)
        @last_measurement_time = last_measurement_time
        @measurements_per_day = measurements_per_day
        @interval = interval
        @use_night = use_night
        @bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(measurements_per_day,
                                                                             interval,
                                                                             last_measurement_time)
      end

      def service_name
        "summarized_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        heart_rate = data_service.heart_rate(from, to)
        offset = 0
        max = 300
        k = 5
        soft_histogram(cluster_in_buckets(heart_rate, from, to), offset, max, k)
      end

      def sleep(from, to)
        sleep = data_service.sleep(from, to)
        cluster_in_buckets(sleep, from, to)
      end

      def calories(from, to)
        calories_measured = data_service.calories(from, to)
        sum_values(cluster_in_buckets(calories_measured, from, to))
      end

      def steps(from, to)
        steps = data_service.steps(from, to)
        sum_values(cluster_in_buckets(steps, from, to))
      end

      def activities(from, to)
        activities = data_service.activities(from, to)
        histogram(cluster_in_buckets(activities, from, to))
      end

      private

      def take_first_value(data)
        data.map { |entry| output_entry(entry[date_time_field], entry[values_field].first) }
      end

      def histogram(data)
        data.map do |entry|
          result = Hash.new(0)
          entry[values_field].each { |val| result[val] += 1 }
          max_value = max_from_hash(result)
          output_entry(entry[date_time_field], max_value)
        end
      end

      def sum_values(data)
        data.map { |entry| output_entry(entry[date_time_field], entry[values_field].sum) }
      end

      def soft_histogram(data, min, max, k)
        data.map do |entry|
          histogram = Hash.new(0)
          entry[values_field].each do |current|
            (current - k..current + k).each { |buck| histogram[buck] += 1 } if current
          end
          histogram.delete_if { |hist_key, _value| hist_key < min || hist_key > max }
          max_value = max_from_hash(histogram)
          output_entry(entry[date_time_field], max_value)
        end
      end

      def max_from_hash(provided_hash)
        return nil unless provided_hash.max
        max_values = provided_hash.map { |key, v| key if v == provided_hash.values.max }.compact
        max_values.sort!
        number_of_elements = max_values.length
        return max_values.first if max_values.any? { |elem| elem.is_a? String }
        (max_values[(number_of_elements - 1) / 2] + max_values[number_of_elements / 2]) / 2.0
      end

      def cluster_in_buckets(data, from, to)
        buckets = @bucket_generator.generate(from, to)
        current_bucket = 0

        # Sort both arrays
        buckets.sort_by! { |entry| entry[date_time_field] }
        data.sort_by! { |entry| entry[date_time_field] }

        data.each do |entry|
          next unless entry[date_time_field]

          # TODO: Binary search?
          while current_bucket < buckets.size && entry[date_time_field] > buckets[current_bucket][date_time_field]
            current_bucket += 1
          end

          break if current_bucket == buckets.size

          # Don't take the night into account
          next unless @use_night
          next unless entry[date_time_field] > (buckets[current_bucket][date_time_field] - @interval.hours)
          values = entry[values_field]
          buckets[current_bucket][values_field] << values
          # TODO: Should be no need to flatten the entire thing every time.
          # TODO: Just flatten whatever you add before adding it and check that your concat works correctly.
          buckets[current_bucket][values_field] = buckets[current_bucket][values_field].flatten
        end
        buckets
      end
    end
  end
end
