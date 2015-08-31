module Imputers
  class SplineImputer < Imputer
    def impute!(y_array)
      len = y_array.length
      x_array = []
      y_array = y_array.map.with_index do |current, index|
        unless need_imputation? current
          x_array[index] = index.to_f
          current.to_f
        end
      end
      x_array.compact!
      y_array.compact!

      spline = Spliner::Spliner.new x_array, y_array, :extrapolate => '100%', emethod: :hold
      res = (0...len).map { |x| spline[x] }
      Rails.logger.info res
      res
    end
  end
end
