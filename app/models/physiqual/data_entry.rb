class DataEntry
  include Virtus.model

  DATE_FORMAT = '%Y-%m-%d'

  attribute :start_date, DateTime
  attribute :end_date, DateTime
  attribute :values, Array
  attribute :measurement_moment, DateTime
end