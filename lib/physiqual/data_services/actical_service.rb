module Physiqual
  module DataServices
    class ActicalService < DataService

      def initialize(session)
        @session = session
      end

      def service_name
        GoogleToken.csrf_token
      end

      def heart_rate(from, to)
        fail Errors::NotSupportedError, 'Heart rate Not supported by Actical!'
      end

      def steps(from, to)
        fail Errors::NotSupportedError, 'Steps Not supported by Actical!'
      end

      def activities(from, to)
        fail Errors::NotSupportedError, 'Activities Not supported by Actical!'
      end

      def calories(from, to)
        fail Errors::NotSupportedError, 'Calories Not supported by Actical!'
      end

      def distance(from, to)
        fail Errors::NotSupportedError, 'Distance Not supported by Actical!'
      end

      def sleep(from, to)
        fail Errors::NotSupportedError, 'Sleep Not supported by Actical!'
      end
    end
  end
end
