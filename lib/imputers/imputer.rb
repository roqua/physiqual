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
      # Return an array of nils if all values need imputation (makes the above line redundant)
      return Array.new(array.size, nil) if array.all? { |elem| need_imputation?(elem) }

      # Return if no nils or -1's
      return array unless array.any? { |elem| need_imputation?(elem) }

      impute_callback array: array
    end

    def impute_callback(array:)
      run_callbacks :process_impute do
        process_impute array
      end
    end

    protected

    def need_imputation?(value)
      # Currently we do not support imputation of strings
      return false if value.is_a? String
      [nil, -1].include? value
    end
  end
end
