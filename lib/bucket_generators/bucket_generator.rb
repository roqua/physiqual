module BucketGenerators
  module BucketGenerator
    def generate(_from, _to)
      fail 'Not implemented by subclass'
    end

    # TODO: This is copied from dataservice. Remove it here and find a better place to store it.
    def output_entry(date, values)
      {
        DataServices::DataService::DATE_TIME_FIELD => date,
        DataServices::DataService::VALUES_FIELD => [values].flatten
      }
    end
  end
end
