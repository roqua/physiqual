module Physiqual
  module DataServices
    class CassandraDataService < DataServiceDecorator
      def initialize(data_service)
        super(data_service)
      end

      def service_name
        "cassandra_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        heart_rate = data_service.heart_rate(from, to)
      end

      def sleep(from, to)
        sleep = data_service.sleep(from, to)
      end

      def calories(from, to)
        calories_measured = data_service.calories(from, to)
      end

      def distance(from, to)
        distance = data_service.distance(from, to)
      end

      def steps(from, to)
        steps = data_service.steps(from, to)
      end

      def activities(from, to)
        activities = data_service.activities(from, to)
      end

      private

      
    end
  end
end
