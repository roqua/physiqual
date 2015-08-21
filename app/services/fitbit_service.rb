class FitbitService < DataService
  include HTTParty

  base_uri FitbitToken.base_uri

  def initialize(token)
    @token = token
    @header = { 'Authorization' => "Bearer #{@token.token}" }
  end

  def profile
    send_get('/profile.json')
  end

  def sleep(from)
    from = from.strftime(DATE_FORMAT)

    send_get("/sleep/date/#{from}.json")
  end

  def steps(from, to)
    from = from.strftime(DATE_FORMAT)
    to = to.strftime(DATE_FORMAT)

    steps = send_get("/activities/steps/date/#{from}/#{to}.json")
    retval = {}
    retval[key] = steps['activities-steps']
    retval
  end

  private

  def send_get(url)
    result = self.class.get(url, headers: @header)
    result = result.body
    JSON.parse(result)
  end
end
