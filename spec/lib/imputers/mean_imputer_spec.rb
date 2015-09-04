require 'rails_helper'

require 'shared_examples_for_imputers'

module Imputers
  describe MeanImputer do
    it_behaves_like 'an imputer'

    let!(:unimputed_array) { [nil, 1, 2, 3, nil, nil, 6, nil, 9] }
    let!(:mean) { unimputed_array.compact.sum / unimputed_array.compact.length }
    let(:result) { described_class.impute!(unimputed_array.dup) }

    it 'should impute all missing values' do
      expect(result).to_not include(nil)
    end

    it 'should impute all missing values with the mean' do
      missings = unimputed_array.map.with_index { |item, index| item.nil? ? index : nil }.compact
      missings.each { |id| expect(result[id]).to eq mean }
    end
  end
end
