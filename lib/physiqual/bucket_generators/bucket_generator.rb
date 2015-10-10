module Physiqual
  module BucketGenerators
    module BucketGenerator
      def generate(_from, _to)
        fail 'Not implemented by subclass'
      end

      # Note that this function is no longer equivalent to the output_entry definition from data services.
      # The below output_entry function is used only for returning data from a bucket generator and
      # contains additional information about bucket start times.
      def output_entry(start_date, date, values)
        {
          DataServices::DataService::DATE_TIME_START_FIELD => start_date,
          DataServices::DataService::DATE_TIME_FIELD => date,
          DataServices::DataService::VALUES_FIELD => [values].flatten
        }
      end
    end
  end
end
