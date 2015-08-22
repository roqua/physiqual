class DataServiceFactory
  def self.fabricate!(service, token)
    case service
    when GoogleService.service_name
      return GoogleService.new(token)

    when FitbitService.service_name
      return FitbitService.new(token)

    else
      fail "Service #{service} not found"
    end
  end
end
