module Physiqual
  require 'rails_helper'
  
  require 'shared_context_for_data_services'
  module BucketGenerators
    describe EquidistantBucketGenerator do
      let(:interval) { 6 }
      let(:measurements_per_day) { 3 }
      let(:last_measurement_time) { Time.now.change(hour: 22, min: 30, usec: 0) }
      let(:subject) { described_class.new(measurements_per_day, interval, last_measurement_time) }
  
      include_context 'data_service context'
  
      describe 'generate' do
        before do
          @result = subject.generate(from, to)
          @dates = @result.map { |x| x[DataServices::DataService::DATE_TIME_FIELD] }
        end
  
        it 'should output the correct format' do
          check_result_format(@result)
        end
  
        it 'should generate date buckets as expected' do
          current = from.to_date
          @dates.each_with_index do |date, index|
            expect(date.to_date).to eq current
            current += 1.day if ((index + 1) % measurements_per_day) == 0
          end
        end
  
        it 'should generate time buckets as expected' do
          start = last_measurement_time - (interval * (measurements_per_day - 1)).hours
          current = start.dup
          @dates.each_with_index do |date, index|
            expect(date.hour).to eq current.hour
            expect(date.min).to eq current.min
            current += interval.hours
            current = current.change(hour: start.hour, min: start.min) if ((index + 1) % measurements_per_day) == 0
          end
        end
      end
    end
  end
end
