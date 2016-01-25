module Physiqual
  class DataEntry
    include Virtus.model

    DATE_FORMAT = '%Y-%m-%d'.freeze

    attribute :start_date, DateTime
    attribute :end_date, DateTime
    attribute :values, Array, default: []
    attribute :measurement_moment, DateTime, default: default_measurement_moment

    def default_measurement_moment
      return nil if start_date.nil? || end_date.nil?
      Time.at((start_date + end_date) / 2)
    end
  end
end
