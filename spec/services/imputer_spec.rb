shared_examples_for "an imputer" do
  let(:instance) { described_class.new}
  it 'should define an impute! funcion' do
    expect(instance.methods).to include :impute!
  end

  describe 'should have an impute function that returns an array with the same number of elements' do
    after :each do
      result = instance.impute! @elements
      expect(result.length).to eq @elements.length
    end

    it 'with a regular array' do
      @elements = [1,2,3,4,5]
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
end
