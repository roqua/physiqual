class DataAggregator
  def initialize(data_services, imputers)
    @data_services = [data_services].flatten
    @imputers = [imputers].flatten
  end

  def steps(from, to)
    result = retrieve_data_of_all_services { |service| service.steps(from, to) }
    run_function(result) do |steps, results, key|
      [steps[key], results[key]].flatten.max if valid_result? results[key]
    end
  end

  def heart_rate(from, to)
    result = retrieve_data_of_all_services { |service| service.heart_rate(from, to) }
    run_function(result) do |heart_rates, results, key|
      [heart_rates[key], results[key]].flatten.max if valid_result? results[key]
    end
  end

  def sleep(from, to)
    result = retrieve_data_of_all_services { |service| service.sleep(from, to) }
    run_function(result) do |sleep_data, results, key|
      [sleep_data[key], results[key]].max if valid_result? results[key]
    end
  end

  def calories(from, to)
    result = retrieve_data_of_all_services { |service| service.calories(from, to) }
    run_function(result) do |calories, results, key|
      [calories[key], results[key]].flatten.max if valid_result? results[key]
    end
  end

  def activities(from, to)
    result = retrieve_data_of_all_services { |service| service.activities(from, to) }
    run_function(result) do |_activities, results, key|
      results[key] if valid_result? results[key]
    end
  end

  private

  def valid_result?(result)
    !result.compact.blank?
  end

  def run_function(result)
    aggregated_result = Hash.new(-1)
    result.compact.each do |service_result|
      service_result.keys.each do |data_entry_key|
        current_value = yield(aggregated_result, service_result, data_entry_key)
        aggregated_result[data_entry_key] = current_value.nil? ? aggregated_result[data_entry_key] : current_value
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
