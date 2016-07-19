module Physiqual
  class DataEntry
    include Virtus.model

    DATE_FORMAT = '%Y-%m-%d'.freeze

    # The start date property is the start of this dataentry object, meaning it
    # denotes the actual start of the data in this measurement
    attribute :start_date, DateTime
    # The end date property denotes the end of this measurement (exclusing the time).
    # Meaning, data in this data entry is upto, but not including this time point
    attribute :end_date, DateTime
    attribute :values, Array, default: []
    # Measurement moment is used in the physiqual process. It is used to determine
    # the actual 'measurement time' of the current dataentry object. Often it's
    # precisely in the middle of the start and end date of this data entry object.
    attribute :measurement_moment, DateTime, default: :default_measurement_moment

    def default_measurement_moment
      return nil if start_date.nil? || end_date.nil?
      Time.at((start_date.to_i + end_date.to_i) / 2)
    end
  end
end
