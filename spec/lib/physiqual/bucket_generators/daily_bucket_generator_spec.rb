require 'rails_helper'

require 'shared_context_for_bucket_generators'
module Physiqual
  module BucketGenerators
    describe DailyBucketGenerator do
      let(:measurement_times) do
        [
          Time.zone.now.change(hour: 03, min: 03, usec: 0),
          Time.zone.now.change(hour: 8, min: 55, usec: 0),
          Time.zone.now.change(hour: 10, min: 10, usec: 0),
          Time.zone.now.change(hour: 23, min: 30, usec: 0)
        ]
      end
      let(:hours_before_first_measurement) { 6 }
      let(:subject) { described_class.new(measurement_times, hours_before_first_measurement) }

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
            current += 1.day if ((index + 1) % measurement_times.count) == 0
          end
        end

        it 'should generate time buckets as expected' do
          @dates.each_with_index do |date, index|
            time_index = (index % measurement_times.count)
            current = measurement_times[time_index]
            expect(date.hour).to eq current.hour
            expect(date.min).to eq current.min
          end
        end
      end
    end
  end
end
