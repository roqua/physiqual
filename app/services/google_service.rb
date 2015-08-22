class GoogleService < DataService
  include HTTParty

  base_uri GoogleToken.base_uri

  def initialize(token)
    @token = token
    @header = { 'Authorization' => "Bearer #{@token.token}" }
  end

  def self.service_name
    'google'
  end

  def sources
    @datasources = self.class.get('/dataSources', headers: @header).body
    @datasources = JSON.parse(@datasources)
    @datasources = @datasources['dataSource'].map { |x| [x['dataType']['name'], x['dataStreamId']] }
    @datasources
  end

  def heart_rate(from, to)
    heart_rate_url = 'derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm'
    activity_data(from, to, heart_rate_url, 'fpVal')
  end

  def steps(from, to)
    steps_url = 'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps'
    activity_data(from, to, steps_url, 'intVal')
  end

  private

  def activity_data(from, to, url, value_type)
    from = convert_time_to_nanos(from)
    to = convert_time_to_nanos(to)
    res = access_datasource(url, from, to)
    res = res['point']
    results_hash = Hash.new(0)

    res.each do |entry|
      start = (entry['startTimeNanos'].to_i / 10e8).to_i
      endd = (entry['endTimeNanos'].to_i / 10e8).to_i
      actual_timestep = Time.at((start + endd) / 2)
      value = entry['value'].first[value_type].to_i
      results_hash[actual_timestep] += value
    end
    results = {}

    results[key] = []
    results_hash.each { |date, value| results[key] << { date_time => date, 'value' => value } }
    results
  end

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
