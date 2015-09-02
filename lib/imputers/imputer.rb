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
      # Return if only nils
      return array if array.compact.blank?

      #Return if no nils or -1's
      return array if !array.any? {|elem| [nil, -1].include?(elem) }

      # Return if it contains strings
      return array if array.any? {|elem| elem.is_a? String }
      impute_callback array: array
    end

    def impute_callback(array:)
      run_callbacks :process_impute do
        process_impute array
      end
    end

    protected

    def need_imputation?(value)
      value.nil? || value < 0
    end
  end
end
