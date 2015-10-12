module Physiqual
  module DataServices
    class SummarizedDataService < DataServiceDecorator
      def initialize(data_service, bucket_generator)
        super(data_service)
        @bucket_generator = bucket_generator
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

        # Sort data array
        data.sort_by! { |entry| entry[date_time_field] }

        data.each do |entry|
          next unless entry[date_time_field]

          while current_bucket < buckets.size && entry[date_time_field] > buckets[current_bucket][date_time_field]
            current_bucket += 1
          end

          break if current_bucket == buckets.size

          unless entry[date_time_field] > buckets[current_bucket][date_time_start_field]
            next
          end
          values = entry[values_field]
          buckets[current_bucket][values_field].push(*values)
        end
        # remove the extra information
        buckets.each_with_index do |_bucket, bucket_index|
          buckets[bucket_index].delete(date_time_start_field)
        end
        buckets
      end
    end
  end
end
