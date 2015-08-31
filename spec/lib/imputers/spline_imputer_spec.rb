require 'rails_helper'

require 'shared_examples_for_imputers'

module Imputers
  describe SplineImputer do
    let!(:instance) { SplineImputer.new }

    it_behaves_like 'an imputer'

    it 'should impute values' do
      y_array = [1, 2, 3, 4, 5, 6, nil, nil, 9, 10]
      expected = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
      result = instance.impute! y_array
      expect(result.length).to be_equal(y_array.length)
      expected.each_with_index { |val, index| expect(val).to be_within(0.0001).of(result[index]) }
    end
  end
end
