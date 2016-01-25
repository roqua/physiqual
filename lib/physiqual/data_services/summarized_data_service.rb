module Physiqual
  module DataServices
    class SummarizedDataService < DataServiceDecorator
      def initialize(data_service)
        super(data_service)
      end

      def service_name
        "summarized_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        heart_rate = data_service.heart_rate(from, to)
        offset = 0
        max = 300
        k = 5
        soft_histogram(heart_rate, offset, max, k)
      end

      def sleep(from, to)
        data_service.sleep(from, to)
      end

      def calories(from, to)
        calories_measured = data_service.calories(from, to)
        sum_values(calories_measured)
      end

      def distance(from, to)
        distance = data_service.distance(from, to)
        sum_values(distance)
      end

      def steps(from, to)
        steps = data_service.steps(from, to)
        sum_values(steps)
      end

      def activities(from, to)
        activities = data_service.activities(from, to)
        histogram(activities)
      end

      private

      def take_first_value(data)
        data.map do |entry|
          entry.values = [entry.values.first].flatten
          entry
        end
      end

      def histogram(data)
        data.map do |entry|
          result = Hash.new(0)
          entry.values.each { |val| result[val] += 1 }
          max_value = max_from_hash(result)
          entry.values = [max_value].flatten
          entry
        end
      end

      def sum_values(data)
        data.map do |entry|
          entry.values = [entry.values.sum].flatten
          entry
        end
      end

      def soft_histogram(data, min, max, k)
        data.map do |entry|
          histogram = Hash.new(0)
          entry.values.each do |current|
            (current - k..current + k).each { |buck| histogram[buck] += 1 } if current
          end

          histogram.delete_if { |hist_key, _value| hist_key < min || hist_key > max }
          max_value = max_from_hash(histogram)

          entry.values = [max_value].flatten
          entry
        end
      end

      def max_from_hash(provided_hash)
        # The returned value is the maximum of the "soft histogram" technique.
        # In case of a tie, we choose the value that lies closest to their mean.
        # When there are two such values, we return the maximum of the two.
        #
        # This guarantees that we always return a value that was measured and
        # not the result of intrapolation.

        return nil unless provided_hash.max
        max_values = provided_hash.map { |key, v| key if v == provided_hash.values.max }.compact
        return max_values.first if max_values.any? { |elem| elem.is_a? String }
        representative_value_for_array(max_values)
      end

      def representative_value_for_array(max_values)
        max_values.sort!
        average_max_value = max_values.sum.to_f / max_values.size
        lower_bound, upper_bound = lower_and_upper_bounds(max_values, average_max_value)
        closest_value(max_values[lower_bound], max_values[upper_bound], average_max_value)
      end

      def lower_and_upper_bounds(arr, value)
        return [0, 0] if arr.size == 1
        return [0, 0] if value <= arr[0] # does not occur, included for correctness only
        return [arr.size - 1, arr.size - 1] if value > arr[-1] # does not occur, included for correctness only
        l = 0
        r = arr.size - 1
        while l + 1 != r
          m = (l + r) >> 1
          if arr[m] >= value
            r = m
          else
            l = m
          end
        end
        [l, r]
      end

      def closest_value(lower_bound, upper_bound, average_max_value)
        if upper_bound == lower_bound
          upper_bound
        elsif upper_bound - average_max_value == average_max_value - lower_bound
          [upper_bound, lower_bound].sum.to_f / 2.0
        elsif upper_bound - average_max_value > average_max_value - lower_bound
          lower_bound
        else
          upper_bound
        end
      end
    end
  end
end
