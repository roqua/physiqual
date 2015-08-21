class DataAggregator
  def initialize(data_services)
    @data_services = data_services
  end

  def steps(from, to)
    steps = Hash.new(0)
    @data_services.each do |service|
      service.steps(from, to).keys.each do |current_step|
        steps[current_step] = [steps[current_step], service.steps(from, to)[current_step]].max
      end
    end
    steps
  end
end
