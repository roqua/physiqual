module Imputers
  class MockImputer < Imputer
    def impute!(array)
      array
    end
  end
end
