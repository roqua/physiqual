module Physiqual
  module Imputers
    class LastObservationCarriedForwardImputer < Imputer
      def process_impute(array)
        array.each_with_index do |current, index|
          array[index] = index >= 1 ? array[index - 1] : 0 if need_imputation? current
        end
        array
      end
    end
  end
end
