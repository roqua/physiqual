module Physiqual
  require 'rails_helper'
  
  require 'shared_examples_for_data_services'
  require 'shared_context_for_data_services'
  
  module DataServices
    describe CachedDataService do
      it_behaves_like 'a data_service'
      include_context 'data_service context'
  
      let(:service) { MockService.new(nil) }
      let(:subject) { CachedDataService.new(service) }
  
      describe 'should cache all queries' do
        it 'caches heart_rate' do
          expect(service).to receive(:heart_rate).once
          subject.heart_rate(from, to)
          subject.heart_rate(from, to)
        end
  
        it 'caches sleep' do
          expect(service).to receive(:sleep).once
          subject.sleep(from, to)
          subject.sleep(from, to)
        end
  
        it 'caches calories' do
          expect(service).to receive(:calories).once
          subject.calories(from, to)
          subject.calories(from, to)
        end
  
        it 'caches steps' do
          expect(service).to receive(:steps).once
          subject.steps(from, to)
          subject.steps(from, to)
        end
      end
  
      describe 'steps' do
        before do
          @result = subject.steps(from, to)
        end
  
        it 'returns the steps in the correct format' do
          check_result_format(@result)
        end
  
        it 'gets the steps from the correct date till the correct date' do
          check_start_end_date(@result, from, to)
        end
      end
    end
  end
end
