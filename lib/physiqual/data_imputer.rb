module Physiqual
  class DataImputer
    def initialize(data_service, imputers)
      @data_service = data_service
      @imputers = [imputers].flatten
    end

    def steps(from, to)
      result = @data_service.steps(from, to)
      impute_results(result)
    end

    def heart_rate(from, to)
      result = @data_service.heart_rate(from, to)
      impute_results(result)
    end

    def distance(from, to)
      result = @data_service.distance(from, to)
      impute_results(result)
    end

    def sleep(from, to)
      result = @data_service.sleep(from, to)
      impute_results(result)
    end

    def calories(from, to)
      result = @data_service.calories(from, to)
      impute_results(result)
    end

    def activities(from, to)
      result = @data_service.activities(from, to)
      impute_results(result)
    end

    private

    def valid_result?(result)
      !result.compact.blank?
    end

    def impute_results(results)
      result_hash = Hash.new(-1)

      # Map the results from an array of objects to a hash
      results.each { |result| result_hash[result.end_date] = result.values }

      @imputers.each do |imputer|
        break unless result_hash.values.any? { |x| [nil, -1].include? x }
        imputed_values = imputer.impute! result_hash.values.flatten
        result_hash.each_with_index { |key, index| result_hash[key] = imputed_values[index] }
      end
      result_hash
    end
  end
end
