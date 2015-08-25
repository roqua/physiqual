class KNearestNeighborImputer < Imputer
  def initialize
    @k = 2
  end

  def number_of_neighbors(k)
    @k = k
  end

  def impute!(array)
    array.each_with_index do |current, index|
      next unless need_imputation? current
      from = [0, (index - @k)].max
      to = [array.length-1, (index + @k)].min
      subset = array[from..to]
      next if subset.compact.blank?
      array[index] = subset.sum / subset.length
    end
  end
end
