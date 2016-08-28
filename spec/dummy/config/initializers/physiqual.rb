Physiqual.configure do |config|
  # Google API tokens
  config.google_client_id     = ENV['GOOGLE_CLIENT_ID']
  config.google_client_secret = ENV['GOOGLE_CLIENT_SECRET']

  # Fitbit oauth tokens
  config.fitbit_client_id     = ENV['FITBIT_CLIENT_ID']
  config.fitbit_client_secret = ENV['FITBIT_CLIENT_SECRET']

  # Host settings
  config.host_url             = ENV['HOST_URL'] || 'physiqual.dev'
  config.host_protocol        = ENV['HOST_PROTOCOL'] || 'http'

  # Cassandra settings
  config.enable_cassandra     = ENV['ENABLE_CASSANDRA'] ? ENV['ENABLE_CASSANDRA'].downcase == 'true' : false
  config.cassandra_username   = ENV['CASSANDRA_USERNAME'] || ''
  config.cassandra_password   = ENV['CASSANDRA_PASSWORD'] || ''
  config.cassandra_host_urls  = ENV['CASSANDRA_HOST_URLS'] || 'physiqual.dev'
  config.cassandra_keyspace   = ENV['CASSANDRA_KEYSPACE']
  
  # Redis settings
  config.redis_url            = ENV['REDIS_URL'] || 'physiqual.dev'

  # EMA Settings
  config.measurements_per_day           = 1 # Number of measurements per day
  config.interval                       = 24 # Number of hours between measurements
  config.hours_before_first_measurement = 24 # Number of hours before the first measurement on a day

  # Imputation
  config.imputers             = [Physiqual::Imputers::CatMullImputer]
end
