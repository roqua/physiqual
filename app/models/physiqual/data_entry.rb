class DataEntry
  include Virtus.model

  DATE_FORMAT = '%Y-%m-%d'

  attribute :start_date, DateTime
  attribute :end_date, DateTime
  attribute :values, Array

  def measurement_moment
    @measurement_moment ||= Time.at((start_date + end_date) / 2)
    @measurement_moment
  end
end