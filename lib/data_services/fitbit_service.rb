module DataServices
  class FitbitService < DataService
    @intraday = true
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

    def sleep(from, _to)
      from = from.strftime(DATE_FORMAT)
      data = @session.get("/sleep/date/#{from}.json")
      puts data
      data
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

      if(intraday)
        data = intraday_summary(from, to)
      else
        data = daily_summary(from, to)
      end
      result
    end

    def daily_summary(from, to, activity)
      data = @session.get("/activities/#{activity}/date/#{from}/#{to}.json")
      process_entries(data["activities-#{activity}"])
    end

    def intraday_summary(from,to,activity )
      results = []
      (from.to_date..to.to_date).each do |date|
        data = @session.get("/activities/#{activity}/date/#{from}/1d/1min.json")
        results << process_entries(data["activities-#{activity}-intraday"])
      end
      results.flatten
    end

    def process_entries(entries)
      result = []
      entries.each do |entry|
        value = entry['value']
        value = !value.is_a?(Hash) && value.to_s == value.to_i.to_s ? value.to_i : value
        result << { date_time_field => entry['dateTime'].to_time, values_field => [value] }
      end
      result
    end
  end
end
