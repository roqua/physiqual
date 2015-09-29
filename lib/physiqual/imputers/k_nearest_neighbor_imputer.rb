module Physiqual
  module Imputers
    class KNearestNeighborImputer < Imputer
      def initialize
        @k = 2
      end
  
      def number_of_neighbors(k)
        @k = k
      end
  
      def process_impute(array)
        array.each_with_index do |current, index|
          next unless need_imputation? current
          from = [0, (index - @k)].max
          to = [array.length - 1, (index + @k)].min
          subset = array[from..to].compact
          next if subset.blank?
          array[index] = subset.sum / subset.length
        end
      end
    end
  end
end
