module Physiqual
  class DataAggregator
    def initialize(data_services, imputers)
      @data_services = [data_services].flatten
      @imputers = [imputers].flatten
    end

    def steps(from, to)
      result = retrieve_data_of_all_services { |service| service.steps(from, to) }
      max_from_both_services(result)
    end

    def heart_rate(from, to)
      result = retrieve_data_of_all_services { |service| service.heart_rate(from, to) }
      max_from_both_services(result)
    end

    def distance(from, to)
      result = retrieve_data_of_all_services { |service| service.distance(from, to) }
      max_from_both_services(result)
    end

    def sleep(from, to)
      result = retrieve_data_of_all_services { |service| service.sleep(from, to) }
      max_from_both_services(result)
    end

    def calories(from, to)
      result = retrieve_data_of_all_services { |service| service.calories(from, to) }
      max_from_both_services(result)
    end

    def activities(from, to)
      result = retrieve_data_of_all_services { |service| service.activities(from, to) }
      merge_service_data(result) do |_activities, data_entry|
        data_entry[DataServices::DataService::VALUES_FIELD]
      end
    end

    private

    def max_from_both_services(result)
      merge_service_data(result) do |data_array, data_entry|
        [data_array[data_entry[DataServices::DataService::DATE_TIME_FIELD]],
         data_entry[DataServices::DataService::VALUES_FIELD]].flatten.max
      end
    end

    def valid_result?(result)
      !result.compact.blank?
    end

    def merge_service_data(result)
      aggregated_result = Hash.new(-1)
      result.compact.each do |service_result|
        service_result.each do |data_entry|
          if valid_result? data_entry[DataServices::DataService::VALUES_FIELD]
            current_value = yield(aggregated_result, data_entry)
          end

          if current_value.nil?
            current_value = aggregated_result[data_entry[DataServices::DataService::DATE_TIME_FIELD]]
          end

          aggregated_result[data_entry[DataServices::DataService::DATE_TIME_FIELD]] = current_value
        end
      end
      impute_results(aggregated_result)
    end

    def impute_results(result)
      @imputers.each do |imputer|
        break unless result.values.any? { |x| [nil, -1].include? x }
        imputed_values = imputer.impute! result.values.flatten
        result.keys.each_with_index { |key, index| result[key] = imputed_values[index] }
      end
      result
    end

    def retrieve_data_of_all_services
      fail 'No services defined' if @data_services.compact.blank?
      @data_services.map do |service|
        begin
          yield(service)
        rescue Errors::NotSupportedError => e
          Rails.logger.warn e.message
          nil
        end
      end
    end
  end
end
