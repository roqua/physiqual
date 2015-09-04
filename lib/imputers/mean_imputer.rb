module Imputers
  class MeanImputer < Imputer
    def process_impute(array)
      mean_array = array.compact
      mean = mean_array.sum
      mean /= mean_array.length
      array.each_with_index do |current, index|
        array[index] = mean if need_imputation? current
      end
      array
    end
  end
end
