class DataAggregator
  def initialize(data_services, imputer)
    @data_services = data_services
    @imputer = imputer
  end

  def steps(from, to)
    result = retrieve_data_of_all_services { |service| service.steps(from, to) }
    run_function(result) { |steps, results, key| [steps[key], results[key]].max }
  end

  def heart_rate(from, to)
    result = retrieve_data_of_all_services { |service| service.heart_rate(from, to) }
    run_function(result) { |heart_rates, results, key| [heart_rates[key], results[key]].max unless results[key].nil?  }
  end

  def sleep(_from, _to)
  end

  def calories(_from, _to)
  end

  def activities(_from, _to)
  end

  private

  def run_function(result)
    aggregated_result = Hash.new(0)
    result.each do |service_result|
      service_result.keys.each do |data_entry_key|
        current_value = yield(aggregated_result, service_result, data_entry_key)
        aggregated_result[data_entry_key] = current_value.nil? ? aggregated_result[data_entry_key] : current_value
      end
    end
    aggregated_result
  end

  def retrieve_data_of_all_services
    @imputer.impute! @data_services.map { |service| yield(service) }
  end
end
