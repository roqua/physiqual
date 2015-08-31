module DataServices
  class CachedDataService < SimpleDelegator
    def initialize(data_service)
      super(data_service)
      @cache = {}
    end

    def service_name
      "cached_#{__getobj__.service_name}"
    end

    def heart_rate(from, to)
      from_cache(:heart_rate) { __getobj__.heart_rate(from, to) }
    end

    def sleep(from, to)
      from_cache(:sleep) { __getobj__.sleep(from, to) }
    end

    def calories(from, to)
      from_cache(:calories) { __getobj__.calories(from, to) }
    end

    def steps(from, to)
      from_cache(:steps) { __getobj__.steps(from, to) }
    end

    def activities(from, to)
      from_cache(:activities) { __getobj__.activities(from, to) }
    end

    private

    def from_cache(type)
      Rails.logger.warn("#{type} not from cache.. ") unless @cache.include? type
      @cache[type] = yield unless @cache.include? type
      @cache[type]
    end
  end
end
