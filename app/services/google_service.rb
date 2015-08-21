class GoogleService < DataService
  include HTTParty

  base_uri GoogleToken.base_uri

  def initialize(token)
    @token = token
    @header = { 'Authorization' => "Bearer #{@token.token}" }
  end

  def sources
    @datasources = self.class.get('/dataSources', headers: @header).body
    @datasources = JSON.parse(@datasources)
    @datasources = @datasources['dataSource'].map { |x| [x['dataType']['name'], x['dataStreamId']] }
    @datasources
  end

  def heart_rate(from, to, _precision)
    from = convert_time_to_nanos(from)
    to = convert_time_to_nanos(to)
    heart_rate_url = 'derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm'
    res = access_datasource(heart_rate_url, from, to)
    res = res['point']

    results = Hash.new(0)
    Hash[res.map do |entry|
      start = (entry['startTimeNanos'].to_i / 10e8).to_i
      endd = (entry['endTimeNanos'].to_i / 10e8).to_i
      actual_timestep = Time.at((start + endd) / 2).in_time_zone
      value = entry['value'].first['fpVal'].to_i
      results[actual_timestep] += value
      ["#{actual_timestep}", value]
    end]

    results
  end

  def steps(from, to)
    from = convert_time_to_nanos(from)
    to = convert_time_to_nanos(to)
    steps_url = 'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps'
    res = access_datasource(steps_url, from, to)
    res = res['point']
    results_hash = Hash.new(0)

    res.each do |entry|
      start = (entry['startTimeNanos'].to_i / 10e8).to_i
      endd = (entry['endTimeNanos'].to_i / 10e8).to_i
      actual_timestep = Time.at((start + endd) / 2)

      value = entry['value'].first['intVal'].to_i
      results_hash[actual_timestep] += value
    end
    results = {}

    key = 'activities-steps'
    results[key] = []
    results_hash.each { |date, value| results[key] << { 'dateTime' => date, 'value' => value } }
    results
  end

  private

  def access_datasource(id, from, to)
    send_get("/dataSources/#{id}/datasets/#{from}-#{to}")
  end

  def send_get(url)
    result = self.class.get(url, headers: @header)
    result = result.body
    JSON.parse(result)
  end

  def convert_time_to_nanos(time)
    length = 19
    time = "#{time.to_i}"
    time = "#{time}#{('0' * (length - time.length))}"
    time
  end
end
