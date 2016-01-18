require 'rails_helper'

require 'shared_context_for_bucket_generators'
module Physiqual
  module BucketGenerators
    describe EquidistantBucketGenerator do
      let(:interval) { 6 }
      let(:measurements_per_day) { 3 }
      let(:hours_before_first_measurement) { 6 }
      let(:subject) { described_class.new(measurements_per_day, interval, hours_before_first_measurement) }

      include_context 'bucket_generator context'

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

        it 'should generate the correct number of buckets' do
          # +1 because of the last day, which is not included
          expect(@result.length).to eq(measurements_per_day * ((to.to_date - from.to_date).to_i + 1))
        end

        it 'should generate time buckets as expected' do
          start = from + hours_before_first_measurement.hours
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
