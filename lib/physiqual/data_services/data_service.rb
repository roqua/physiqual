module Physiqual
  module DataServices
    class DataService
      def service_name
        'general dataservice'
      end

      def steps(_from, _to)
        fail 'Subclass does not implement steps method.'
      end

      def heart_rate(_from, _to)
        fail 'Subclass does not implement heart_rate method.'
      end

      def sleep(_from, _to)
        fail 'Subclass does not implement sleep method.'
      end

      def calories(_from, _to)
        fail 'Subclass does not implement calories method.'
      end

      def distance(_from, _to)
        fail 'Subclass does not implement distance method.'
      end

      def activities(_from, _to)
        fail 'Subclass does not implement activities method.'
      end
    end
  end
end
