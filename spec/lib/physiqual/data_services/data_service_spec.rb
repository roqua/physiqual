module Physiqual
  require 'rails_helper'
  require 'shared_context_for_data_services'
  module DataServices
    describe DataService do
      include_context 'data_service context'
      describe 'methods should raise errors' do
        it 'should raise on steps' do
          expect { subject.steps(from, to) }.to raise_error 'Subclass does not implement steps method.'
        end

        it 'should raise on heart_rate' do
          expect { subject.heart_rate(from, to) }.to raise_error 'Subclass does not implement heart_rate method.'
        end

        it 'should raise on sleep' do
          expect { subject.sleep(from, to) }.to raise_error 'Subclass does not implement sleep method.'
        end

        it 'should raise on calories' do
          expect { subject.calories(from, to) }.to raise_error 'Subclass does not implement calories method.'
        end

        it 'should raise on activities' do
          expect { subject.activities(from, to) }.to raise_error 'Subclass does not implement activities method.'
        end
      end
    end
  end
end
