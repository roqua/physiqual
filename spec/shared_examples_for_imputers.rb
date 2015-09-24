shared_examples_for 'an imputer' do
  let(:instance) { described_class.new }

  it 'should define an impute! funcion' do
    expect(instance.methods).to include :process_impute
  end

  describe 'should have an impute function that returns an array with the same number of elements' do
    after :each do
      result = described_class.impute! @elements
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
    result = described_class.impute! elements
    result.each_with_index { |val, _index| expect(val).to be_nil }
  end

  describe 'the input contains strings', focus: true do
    it 'should return the original array if it contains one string' do
      elements = [1, 2, 3, 4, 5, 'jaf', nil, -1]
      result = described_class.impute! elements
      expect(result).to eq(elements)
    end
  end

  it 'only imputes if missing values remain' do
    elements = [1, 2, 3, 4, 5, 8]
    expect_any_instance_of(described_class).to_not receive(:process_impute)
    result = described_class.impute! elements
    expect(result).to eq(elements)
  end

  describe 'with missing values' do
    it 'imputes if missing values remain' do
      elements = [1, 2, 3, nil, 5, 8]
      expect_any_instance_of(described_class).to receive(:process_impute)
      described_class.impute! elements
    end

    it 'imputes if -1s remain' do
      elements = [1, 2, 3, -1, 5, 8]
      expect_any_instance_of(described_class).to receive(:process_impute)
      described_class.impute! elements
    end
  end

  describe 'the original items' do
    let!(:unimputed_array) { [nil, 1, 2, 3, nil, nil, 6, nil, 9, 9, 5, 1, 3, nil] }
    it 'should not change the existing values' do
      result = described_class.impute! unimputed_array.dup
      not_missings = unimputed_array.map.with_index { |item, index| item.nil? ? nil : index }.compact
      not_missings.each { |id| expect(result[id]).to eq unimputed_array[id] }
    end
  end
end
