class KNearestNeighborImputer < Imputer
  def initialize(k)
    @k = k
  end

  def impute!(array)
    array.each_with_index do |current, index|
      next if current
      (index..k).each do |val|
        array[val]
      end
    end
  end
end
