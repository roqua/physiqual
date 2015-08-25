class Imputer
  def impute!(_array)
    fail 'Subclass does not implement impute! method.'
  end

  protected

  def need_imputation?(value)
    value.nil? || value < 0
  end
end
