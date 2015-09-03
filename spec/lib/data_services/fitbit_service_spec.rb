require 'rails_helper'

require 'shared_examples_for_data_services'

module DataServices
  describe FitbitService do
    it_behaves_like 'a data_service'

    let(:token) { FactoryGirl.build(:fitbit_token)}
    let(:subject) { FitbitService.new(token)}
    let(:from) { 10.days.ago.in_time_zone.beginning_of_day }
    let(:to) { 1.days.ago.in_time_zone.beginning_of_day }

    describe 'external services' do
      it 'returns steps in the correct way' do
        expect(subject.steps(from, to)).to eq('')
      end
    end
  end
end
