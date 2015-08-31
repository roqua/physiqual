module DataServices
  class DataServiceFactory
    def self.fabricate!(service, token)
      case service
      when GoogleToken.csrf_token
        return GoogleService.new(token)

      when FitbitToken.csrf_token
        return FitbitService.new(token)

      else
        fail "Service #{service} not found"
      end
    end
  end
end
