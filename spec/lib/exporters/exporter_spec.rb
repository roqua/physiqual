require 'rails_helper'
require 'shared_examples_for_exporters'
require 'shared_context_for_exporters'

module Exporters
  describe Exporter do
    include_context 'exporter context'

    describe 'export_data' do
      xit 'should be tested when ready' do
      end
    end

    describe 'create_services' do
      let(:interval) { 6 }
      let(:measurements_per_day) { 3 }

      it 'should create services for each correct token provided' do
        tokens = [FactoryGirl.build(:fitbit_token), FactoryGirl.build(:google_token)]
        expect(tokens.all?(&:complete?)).to be_truthy

        result = subject.send(:create_services, tokens, last_measurement_time, interval, measurements_per_day)
        expect(result.length).to eq(2)
      end

      describe 'with incomplete services' do
        let(:tokens) { [FactoryGirl.build(:fitbit_token), FactoryGirl.build(:google_token)] }
        before do
          allow(tokens.first).to receive(:complete?).and_return(false)
          expect(tokens.all?(&:complete?)).to be_falsey

          @result = subject.send(:create_services, tokens, last_measurement_time, interval, measurements_per_day)
        end

        it 'should not create a service for a token which is not complete' do
          expect(@result.length).to eq(1)
        end

        it 'should remove the nil-services from the list of services' do
          expect(@result).to_not include(nil)
        end
      end
    end
  end
end
