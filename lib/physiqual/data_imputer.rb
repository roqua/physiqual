module Physiqual
  class DataImputer
    def initialize(data_service, imputers)
      @data_service = data_service
      @imputers = [imputers].flatten
    end

    def steps(from, to)
      result = retrieve_data_from_service { |service| service.steps(from, to) }
      impute_results(result)
    end

    def heart_rate(from, to)
      result = retrieve_data_from_service { |service| service.heart_rate(from, to) }
      impute_results(result)
    end

    def distance(from, to)
      result = retrieve_data_from_service { |service| service.distance(from, to) }
      impute_results(result)
    end

    def sleep(from, to)
      result = retrieve_data_from_service { |service| service.sleep(from, to) }
      impute_results(result)
    end

    def calories(from, to)
      result = retrieve_data_from_service { |service| service.calories(from, to) }
      impute_results(result)
    end

    def activities(from, to)
      result = retrieve_data_from_service { |service| service.activities(from, to) }
      impute_results(result)
    end

    private

    def retrieve_data_from_service
      raise 'No service defined' if @data_service.nil?
      begin
        yield(@data_service)
      rescue Errors::NotSupportedError => e
        Rails.logger.warn e.message
        nil
      end
    end

    def valid_result?(result)
      !result.compact.blank?
    end

    def impute_results(results)
      result_hash = Hash.new(-1)

      # Map the results from an array of objects to a hash
      results.each { |result| result_hash[result.end_date] = result.values.first }

      @imputers.each do |imputer|
        break unless result_hash.values.any? { |x| [nil, -1].include? x }
        imputed_values = imputer.impute! result_hash.values.flatten
        # key.first because an each on a hash gives an array [key, value]
        result_hash.each_with_index { |key_value, index| result_hash[key_value.first] = imputed_values[index] }
      end
      result_hash
    end
  end
end
