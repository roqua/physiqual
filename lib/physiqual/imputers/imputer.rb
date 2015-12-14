module Physiqual
  module Imputers
    class Imputer
      include ActiveSupport::Callbacks
      define_callbacks :process_impute

      def process_impute(_array)
        fail 'Subclass does not implement process_impute! method.'
      end

      def self.impute!(*args)
        new.send(:impute!, *args)
      end

      private

      def impute!(array)
        # Return an array of nils if there are not at least two values that do not need imputation
        nr_values_to_be_imputed = array.count { |elem| need_imputation?(elem) }
        return Array.new(array.size, nil) if nr_values_to_be_imputed + 1 >= array.size

        # Return if no nils or -1's
        return array unless array.any? { |elem| need_imputation?(elem) }

        # Return array if the array contains a string
        return array if array.any? { |elem| elem.is_a? String }

        impute_callback array: array
      end

      def impute_callback(array:)
        run_callbacks :process_impute do
          process_impute array
        end
      end

      protected

      def need_imputation?(value)
        [nil, -1].include? value
      end
    end
  end
end
