shared_examples_for 'an imputer' do
  let(:instance) { described_class.new }
  it 'should define an impute! funcion' do
    expect(instance.methods).to include :impute!
  end

  describe 'should have an impute function that returns an array with the same number of elements' do
    after :each do
      result = instance.impute! @elements
      expect(result.length).to eq @elements.length
    end

    it 'with a regular array' do
      @elements = [1, 2, 3, 4, 5]
    end

    it 'with an array of nils' do
      @elements = [nil, nil, nil, nil]
    end

    it 'with an empty array' do
      @elements = []
    end
  end

  it 'should return an array of only nils when all elements are nil' do
    elements = [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
    result = instance.impute! elements
    result.each_with_index { |val, _index| expect(val).to be_nil }
  end

  describe 'the original items' do
    let!(:unimputed_array) { [nil,1,2,3,nil,nil,6,nil,9,9,5,1,3,nil] }
    it 'should not change the existing values' do
      result = instance.impute! unimputed_array.dup
      not_missings = unimputed_array.map.with_index{ |item, index| item.nil? ? nil : index }.compact
      not_missings.each { |id| expect(result[id]).to eq unimputed_array[id] }
    end
  end
end
