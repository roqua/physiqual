module DataServices
  class FitbitService < DataService
    include HTTParty

    base_uri FitbitToken.base_uri

    def initialize(token)
      @token = token
      @header = { 'Authorization' => "Bearer #{@token.token}" }
    end

    def service_name
      FitbitToken.csrf_token
    end

    def profile
      send_get('/profile.json')
    end

    def heart_rate(from, to)
      activity = 'heart'
      {
        key => activity_call(from, to, activity)[key].map do |value|
          { 'dateTime' => value['dateTime'], 'value' => value['value']['restingHeartRate'] }
        end
      }
    end

    def sleep(from, to)
      from = from.strftime(DATE_FORMAT)
      to = to.strftime(DATE_FORMAT)

      send_get("/sleep/date/#{from}/#{to}.json")
    end

    def steps(from, to)
      activity_call(from, to, 'steps')
    end

    def activities(from, to)
      raise RuntimeError
    end

    private

    def activity_call(from, to, activity)
      from = from.strftime(DATE_FORMAT)
      to = to.strftime(DATE_FORMAT)
      data = send_get("/activities/#{activity}/date/#{from}/#{to}.json")
      { key => data["activities-#{activity}"] }
    end

    def send_get(url)
      result = self.class.get(url, headers: @header)
      result = result.body
      JSON.parse(result)
    end
  end
end
