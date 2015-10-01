require 'interpolator'

module Physiqual
  module Imputers
    class CatMullImputer < Imputer
      def process_impute(array)
        len = array.length
        x_array = []
        y_array = array.map.with_index do |current, index|
          unless need_imputation? current
            x_array[index] = index.to_f
            current.to_f
          end
        end
        x_array.compact!
        y_array.compact!
        hash = {}
        x_array.each_with_index { |v, i| hash[v] = y_array[i] }
        spline = ::Interpolator::Table.new hash
        spline.style = 5
        (0...len).map { |x| spline.interpolate x }
      end
    end
  end
end
