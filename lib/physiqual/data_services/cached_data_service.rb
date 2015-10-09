module Physiqual
  module DataServices
    class CachedDataService < DataServiceDecorator
      def initialize(data_service)
        super(data_service)
        @cache = {}
      end

      def service_name
        "cached_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        from_cache(:heart_rate) { data_service.heart_rate(from, to) }
      end

      def sleep(from, to)
        from_cache(:sleep) { data_service.sleep(from, to) }
      end

      def calories(from, to)
        from_cache(:calories) { data_service.calories(from, to) }
      end

      def steps(from, to)
        from_cache(:steps) { data_service.steps(from, to) }
      end

      def activities(from, to)
        from_cache(:activities) { data_service.activities(from, to) }
      end

      def distance(from, to)
        from_cache(:distance) { data_service.distance(from, to) }
      end

      private

      def from_cache(type)
        Rails.logger.warn("#{type} of #{service_name} not from cache.. ") unless @cache.include? type
        @cache[type] = yield unless @cache.include? type
        @cache[type]
      end
    end
  end
end
