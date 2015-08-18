class FitbitService < DataService
  include HTTParty

  base_uri FitbitToken.base_uri


  def initialize(token)
    @token = token
    @header = {'Authorization' => "Bearer #{@token.token}"}
  end

  def get_profile
    send_get('/profile.json')
  end

  def get_sleep(from)
    from = from.strftime(DATE_FORMAT)

    send_get("/sleep/date/#{from}.json")
  end

  def get_steps(from, to)
    from = from.strftime(DATE_FORMAT)
    to = to.strftime(DATE_FORMAT)

    send_get("/activities/steps/date/#{from}/#{to}.json")
  end

  private
  def send_get(url)

    result = self.class.get(url, headers: @header)
    result = result.body
    JSON.parse(result)
  end
end
