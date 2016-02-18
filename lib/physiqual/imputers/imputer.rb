module Physiqual
  module Imputers
    class Imputer
      include ActiveSupport::Callbacks
      define_callbacks :process_impute

      def process_impute(_array)
        raise 'Subclass does not implement process_impute! method.'
      end

      def self.impute!(*args)
        new.send(:impute!, *args)
      end

      private

      def impute!(array)
        nr_values_to_be_imputed = array.count { |elem| need_imputation?(elem) }
        # Return an array of a single value if there is only one single non-nil/-1 value
        return Array.new(array.size, single_value(array)) if nr_values_to_be_imputed + 1 == array.size
        # Return an array of nils if all values need imputation
        return Array.new(array.size, nil) if nr_values_to_be_imputed == array.size

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

      def single_value(array)
        array.find { |elem| !need_imputation?(elem) }
      end
    end
  end
end
