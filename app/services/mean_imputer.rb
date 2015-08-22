class MeanImputer < Imputer
  def impute!(array)
    mean = array.compact
    mean = mean.sum / mean.length
    array.each_with_index do |current, index|
      array[index] = mean if current.nil?
    end
    array
  end
end
