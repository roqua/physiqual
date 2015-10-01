Physiqual.configure do |config|
  config.google_client_id     = ENV['GOOGLE_CLIENT_ID']
  config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']
  config.fitbit_client_id     = ENV['FITBIT_CLIENT_ID']
  config.fitbit_client_secret = ENV['FITBIT_CLIENT_SECRET']

  config.host_url             = ENV['HOST_URL'] || 'physiqual.dev'
  config.host_protocol        = ENV['HOST_PROTOCOL'] || 'http'
end
