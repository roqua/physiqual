module Physiqual
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

      describe 'create_service' do
        before :each do
          allow(Physiqual).to receive(:interval).and_return(6)
          allow(Physiqual).to receive(:measurements_per_day).and_return(3)
          allow(Physiqual).to receive(:hours_before_first_measurement).and_return(6)
        end

        it 'should create a fitbit service for a correct fitbittoken provided' do
          token = FactoryGirl.build(:fitbit_token)
          expect(token.complete?).to be_truthy
          bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(
            Physiqual.measurements_per_day,
            Physiqual.interval,
            Physiqual.hours_before_first_measurement
          )
          result = subject.send(:create_service, token, bucket_generator)
          expect(result.service_name).to end_with('fitbit_oauth2')
        end

        it 'should create a fitbit service for a correct fitbittoken provided' do
          token = FactoryGirl.build(:google_token)
          expect(token.complete?).to be_truthy
          bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(
            Physiqual.measurements_per_day,
            Physiqual.interval,
            Physiqual.hours_before_first_measurement
          )
          result = subject.send(:create_service, token, bucket_generator)
          expect(result.service_name).to end_with('google_oauth2')
        end

        describe 'with incomplete services' do
          let(:token) { FactoryGirl.build(:fitbit_token) }
          it 'should not create a service for a token which is not complete, but should return an empty array' do
            allow(token).to receive(:complete?).and_return(false)
            expect(token.complete?).to be_falsey
            bucket_generator = BucketGenerators::EquidistantBucketGenerator.new(
              Physiqual.measurements_per_day,
              Physiqual.interval,
              Physiqual.hours_before_first_measurement
            )
            result = subject.send(:create_service, token, bucket_generator)
            expect(result).to eq([])
          end
        end
      end
    end
  end
end
