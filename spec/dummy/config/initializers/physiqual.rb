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

  # EMA Settings
  config.measurements_per_day           = 1 # Number of measurements per day
  config.interval                       = 24 # Number of hours between measurements
  config.hours_before_first_measurement = 24 # Number of hours before the first measurement on a day

  # Imputation
  config.imputers             = [Physiqual::Imputers::CatMullImputer]
end
