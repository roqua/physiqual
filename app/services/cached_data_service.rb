class CachedDataService < DataServiceDecorator
  def initialize(data_service)
    super(data_service)
    @cache = {}
  end

  def heart_rate(from, to)
    data_service.heart_rate(from, to)
  end

  def sleep(from, to)
    data_service.sleep(from, to)
  end

  def calories(from, to)
    data_service.calories(from, to)
  end

  def steps(from, to)
    Rails.logger.warn('steps not from cache.. ') unless @cache.include? :steps
    @cache[:steps] = data_service.steps(from, to) unless @cache.include? :steps
    @cache[:steps]
  end
end
