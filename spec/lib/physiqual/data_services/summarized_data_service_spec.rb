module Physiqual
  require 'rails_helper'
  
  require 'shared_examples_for_data_services'
  require 'shared_context_for_data_services'
  
  module DataServices
    describe SummarizedDataService do
      # TODO: This should be figured out, how does it work to have a decorator pattern where one of the classes
      # also receives some other things during initialization
  
      let(:last_measurement_time) { Time.now.change(hour: 22, min: 30, usec: 0) }
      let(:interval) { 6 }
      let(:measurements_per_day) { 3 }
      let(:service) { MockService.new(nil) }
      let(:subject) do
        SummarizedDataService.new(service,
                                  last_measurement_time,
                                  measurements_per_day,
                                  interval, false)
      end
  
      it_behaves_like 'a data_service'
      include_context 'data_service context'
  
      describe 'cluster_in_buckets' do
        let(:data) { service.steps(from, to) }
        let(:from_subset) { (to - 1.day).beginning_of_day }
        let(:to_subset) { (to - 1.day).end_of_day }
        let(:data_subset) { data.select! { |x| x[subject.date_time_field].to_date == (from_subset).to_date } }
  
        it 'should output the correct format' do
          @result = subject.send(:cluster_in_buckets, data, from, to)
          check_result_format(@result)
        end
  
        it 'should correctly cluster the data into buckets' do
          res = []
  
          last_measuremnt_date_time = from_subset.change(hour: last_measurement_time.hour, min: last_measurement_time.min)
          (0...measurements_per_day).each do |meas|
            beginn = last_measuremnt_date_time - ((meas + 1) * interval).hours
            endd = last_measuremnt_date_time - (meas * interval).hours
            res << data.select { |x| x[subject.date_time_field] <= endd && x[subject.date_time_field] > beginn }
          end
  
          # The results in this example are the other way around, reverse them
          res.reverse!
  
          full_result = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
          res.each_with_index do |current_res, index|
            # The results can be sorted, as the order in the values does not matter
            expected = current_res.map { |x| x[subject.values_field] }.flatten.sort
            result = full_result[index][subject.values_field].sort
            expect(result.size).to eq expected.size
            expect(result).to eq expected
          end
        end
  
        describe 'should take the night flag into account' do
          before do
            subject = SummarizedDataService.new(service,
                                                last_measurement_time,
                                                measurements_per_day,
                                                interval, true)
            full_with_night = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
            @full_with_night = full_with_night.first[subject.values_field].sort
  
            subject = SummarizedDataService.new(service,
                                                last_measurement_time,
                                                measurements_per_day,
                                                interval, false)
            full_without_night = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
            @full_without_night = full_without_night.first[subject.values_field].sort
          end
  
          # Should have more elements
          it { expect(@full_with_night.size).to be > (@full_without_night.length) }
  
          # Should be a superset
          it { expect(@full_without_night - @full_with_night).to be_blank }
        end
      end
  
      describe 'max_from_hash' do
        it 'always gets the median max value on a tie' do
          data = { 1 => 1, 2 => 1, 3 => 1, 4 => 1 }
          result = subject.send(:max_from_hash, data)
          expect(result).to eq(2.5)
        end
  
        it 'returns the highest value from a hash of values' do
          data = { 1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 2 }
          result = subject.send(:max_from_hash, data)
          expect(result).to eq(5)
        end
  
        it 'returns the most occuring string if it has only strings' do
          data = { 'test 1' => 1, 'test2' => 1, 'test3' => 1, 'test4' => 2 }
          result = subject.send(:max_from_hash, data)
          expect(result).to eq('test4')
        end
  
        it 'returns the first string if there is a draw' do
          data = { 'test 1' => 1, 'test2' => 1, 'test3' => 1 }
          result = subject.send(:max_from_hash, data)
          expect(result).to eq('test 1')
        end
      end
  
      describe 'with generated buckets' do
        before do
          @data = service.steps(from, to)
          @data = subject.send(:cluster_in_buckets, @data, from, to)
        end
  
        describe 'generate results in the correct format' do
          after(:each) do
            check_result_format(@result)
          end
  
          describe 'sum_values' do
            it 'should output the correct format' do
              @result = subject.send(:sum_values, @data)
            end
          end
  
          describe 'take_first_value' do
            it 'should output the correct format' do
              @result = subject.send(:take_first_value, @data)
            end
          end
  
          describe 'histogram' do
            it 'should output the correct format' do
              @result = subject.send(:histogram, @data)
            end
          end
  
          describe 'soft_histogram' do
            it 'should output the correct format' do
              min = 0
              max = 300
              k = 2
              @result = subject.send(:soft_histogram, @data, min, max, k)
            end
          end
        end
  
        describe 'histogram' do
          it 'behaves like a histogram' do
            data = [{ subject.values_field => [1, 2, 3, 4] }]
            expected = { 1 => 1, 2 => 1, 3 => 1, 4 => 1 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:histogram, data)
          end
        end
  
        describe 'soft_histogram' do
          let(:min) { 0 }
          let(:max) { 300 }
          let(:k) { 1 }
  
          it 'should also increase the k surrounding buckets' do
            data = [{ subject.values_field => [5, 7] }]
            expected = { 4 => 1, 5 => 1, 6 => 2, 7 => 1, 8 => 1 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:soft_histogram, data, min, max, k)
          end
  
          it 'should take the max into account' do
            min = 10
            data = [{ subject.values_field => [15, 8, 8, 8, 8] }]
            expected = { 14 => 1, 15 => 1, 16 => 1 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:soft_histogram, data, min, max, k)
  
            min = 9
            expected = { 9 => 4, 14 => 1, 15 => 1, 16 => 1 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:soft_histogram, data, min, max, k)
          end
  
          it 'should take the max into account' do
            max = 10
            data = [{ subject.values_field => [5, 12, 12, 12, 12] }]
            expected = { 4 => 1, 5 => 1, 6 => 1 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:soft_histogram, data, min, max, k)
  
            max = 11
            expected = { 4 => 1, 5 => 1, 6 => 1, 11 => 4 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:soft_histogram, data, min, max, k)
          end
  
          it 'should produce the expected result' do
            k = 2
            min = 5
            max = 20
            data = [{ subject.values_field => [1, 1, 1, 2, 2, 3, 4, 4, 5, 8, 10, 12, 12, 12, 66] }]
            expected = { 5 => 4, 6 => 4, 7 => 2, 10 => 5, 11 => 4, 12 => 4, 13 => 3, 14 => 3, 8 => 2, 9 => 2 }
            expect(subject).to receive(:max_from_hash).with(expected).and_call_original
            result = subject.send(:soft_histogram, data, min, max, k)
            expect(result.first[subject.values_field]).to eq([10])
  
            min = 0
            expected = { 3 => 9, 4 => 6, 5 => 4, 6 => 4, 7 => 2, 10 => 5, 11 => 4, 12 => 4, 13 => 3, 14 => 3, 8 => 2,
                         9 => 2, 0 => 5, 1 => 6, 2 => 8 }
            expect(subject).to receive(:max_from_hash).with(expected).and_call_original
            result = subject.send(:soft_histogram, data, min, max, k)
            expect(result.first[subject.values_field]).to eq([3])
          end
        end
  
        describe 'sum_values' do
          it 'should sum the values according to the buckets' do
            result = subject.send(:sum_values, @data).map { |x| x[subject.values_field] }
            expected = @data.map { |x| [x[subject.values_field].sum] }
  
            expected.zip(result) do |value, result_value|
              expect(value).to eq(result_value)
            end
          end
        end
      end
    end
  end
end
