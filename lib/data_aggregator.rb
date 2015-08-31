class DataAggregator
  def initialize(data_services, imputers)
    @data_services = [data_services].flatten
    @imputers = [imputers].flatten
  end

  def steps(from, to)
    result = retrieve_data_of_all_services { |service| service.steps(from, to) }
    run_function(result) { |steps, results, key| [steps[key], results[key]].max }
  end

  def heart_rate(from, to)
    result = retrieve_data_of_all_services { |service| service.heart_rate(from, to) }
    run_function(result) { |heart_rates, results, key| [heart_rates[key], results[key]].max unless results[key].nil?  }
  end

  def sleep(from, to)
    result = retrieve_data_of_all_services { |service| service.sleep(from, to) }
    run_function(result) { |sleep_data, results, key| [sleep_data[key], results[key]].max unless results[key].nil?  }
  end

  def calories(from, to)
    result = retrieve_data_of_all_services { |service| service.calories(from, to) }
    run_function(result) { |calories, results, key| [calories[key], results[key]].max unless results[key].nil?  }
  end

  def activities(from, to)
    result = retrieve_data_of_all_services { |service| service.activities(from, to) }
    run_function(result) { |activities, results, key| [activities[key], results[key]].max unless results[key].nil?  }
  end

  private

  def run_function(result)
    aggregated_result = Hash.new(-1)
    result.each do |service_result|
      service_result.keys.each do |data_entry_key|
        current_value = yield(aggregated_result, service_result, data_entry_key)
        aggregated_result[data_entry_key] = current_value.nil? ? aggregated_result[data_entry_key] : current_value
      end
      hoi = impute_results(aggregated_result)
      Rails.logger.debug 'Pre'
      Rails.logger.debug hoi
      Rails.logger.debug 'post'
    end
  end

  def impute_results(result)
    @imputers.each do |imputer|
      break unless result.values.include? nil
      imputed_values = imputer.impute! result.values
      result.keys.each_with_index { |key, index| result[key] = imputed_values[index] }
    end
    result
  end

  def retrieve_data_of_all_services
    fail 'No services defined' if @data_services.compact.blank?
    @data_services.map do |service|
      begin
        yield(service)
      rescue RuntimeError => e
        Rails.logger.warn "#{e.message} < Not supported"
        nil
      end
    end
  end
end
