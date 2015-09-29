module Physiqual
  module Imputers
    class MockImputer < Imputer
      def process_impute(array)
        array
      end
    end
  end
end
