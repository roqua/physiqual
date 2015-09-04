module DataServices
  class FitbitService < DataService
    def initialize(session)
      @session = session
    end

    def service_name
      FitbitToken.csrf_token
    end

    def profile
      @session.get('/profile.json')
    end

    def heart_rate(from, to)
      activity = 'heart'
      activity_call(from, to, activity).map do |hash|
        { date_time_field => hash[date_time_field], values_field => [hash[values_field].first['restingHeartRate']] }
      end
    end

    def sleep(from, to)
      from = from.strftime(DATE_FORMAT)
      to = to.strftime(DATE_FORMAT)

      @session.get("/sleep/date/#{from}/#{to}.json")
    end

    def steps(from, to)
      activity_call(from, to, 'steps')
    end

    def calories(_from, _to)
      fail Errors::NotSupportedError, 'Calories not supported by fitbit!'
    end

    def activities(_from, _to)
      fail Errors::NotSupportedError, 'Activities Not supported by fitbit!'
    end

    private

    def activity_call(from, to, activity)
      from = from.strftime(DATE_FORMAT)
      to = to.strftime(DATE_FORMAT)
      data = @session.get("/activities/#{activity}/date/#{from}/#{to}.json")
      result = []
      data["activities-#{activity}"].each do |entry|
        value = entry['value']
        value = !value.is_a?(Hash) && value.to_s == value.to_i.to_s ? value.to_i : value
        result << { date_time_field => entry['dateTime'].to_time, values_field => [value] }
      end
      result
    end
  end
end
