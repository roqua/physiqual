require 'spliner'

module Physiqual
  module Imputers
    class SplineImputer < Imputer
      def process_impute(y_array)
        return y_array if y_array.compact.blank?
        len = y_array.length
        x_array = []
        y_array = y_array.map.with_index do |current, index|
          return y_array if current.is_a? String
          unless need_imputation? current
            x_array[index] = index.to_f
            current.to_f
          end
        end
        x_array.compact!
        y_array.compact!

        spline = Spliner::Spliner.new x_array, y_array, extrapolate: '100%', emethod: :hold
        res = (0...len).map { |x| spline[x] }
        Rails.logger.info res
        res
      end
    end
  end
end
