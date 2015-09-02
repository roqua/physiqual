require 'rails_helper'

require 'shared_examples_for_data_service_decorators'

module DataServices
  describe CachedDataService do
    it_behaves_like 'a data_service decorator'
    let(:token) { FactoryGirl.create(:fitbit_token) }
    let(:service) { MockFitbitService.new }
    let(:instance) { CachedDataService.new(service) }
    let(:from) { 10.days.ago.in_time_zone.beginning_of_day }
    let(:to)   { 1.days.ago.in_time_zone.end_of_day }

    describe 'should cache all queries' do
      it 'caches heart_rate' do
        expect(service).to receive(:heart_rate).once
        instance.heart_rate(from, to)
        instance.heart_rate(from, to)
      end

      it 'caches sleep' do
        expect(service).to receive(:sleep).once
        instance.sleep(from, to)
        instance.sleep(from, to)
      end

      it 'caches calories' do
        expect(service).to receive(:calories).once
        instance.calories(from, to)
        instance.calories(from, to)
      end

      it 'caches steps' do
        expect(service).to receive(:steps).once
        instance.steps(from, to)
        instance.steps(from, to)
      end
    end
  end
end
