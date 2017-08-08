module Physiqual
  module DataServices
    class DataServiceFactory
      def self.fabricate!(service, session)
        case service
        when GoogleToken.csrf_token
          GoogleService.new(session)

        when FitbitToken.csrf_token
          FitbitService.new(session)

        else
          raise "Service #{service} not found"
        end
      end
    end
  end
end
