module Physiqual
  module DataServices
    class DataServiceFactory
      def self.fabricate!(service, session)
        case service
          when GoogleToken.csrf_token
            return GoogleService.new(session)

          when FitbitToken.csrf_token
            return FitbitService.new(session)

          when ActicalToken.csrf_token
            return ActicalService.new(session)

          else
            fail "Service #{service} not found"
        end
      end
    end
  end
end
