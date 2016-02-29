# rubocop:disable Metrics/ModuleLength
module Physiqual
  require 'rails_helper'

  require 'shared_examples_for_data_services'
  require 'shared_context_for_data_services'

  module DataServices
    describe SummarizedDataService do
      # TODO: This should be figured out, how does it work to have a decorator pattern where one of the classes
      # also receives some other things during initialization

      let(:service) { MockService.new(nil) }
      let(:subject) { SummarizedDataService.new(service) }

      it_behaves_like 'a data_service'
      include_context 'data_service context'

      describe 'max_from_hash' do
        it 'always gets the mean value closest to the mean of the max values on a tie' do
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

      describe 'representative_value_for_array' do
        it 'always gets the mean value closest to the mean of the values on a tie' do
          data = [1, 2, 3, 4]
          result = subject.send(:representative_value_for_array, data)
          expect(result).to eq(2.5)
        end

        it 'returns the highest value from a hash of values' do
          data = [5]
          result = subject.send(:representative_value_for_array, data)
          expect(result).to eq(5)
        end
      end

      describe 'lower_and_upper_bounds' do
        it 'works when there is just one item' do
          data = [3]
          result = subject.send(:lower_and_upper_bounds, data, 3)
          expect(result).to eq([0, 0])
        end

        it 'works when there are two items' do
          data = [0, 1]
          result = subject.send(:lower_and_upper_bounds, data, 0.5)
          expect(result).to eq([0, 1])
        end

        it 'returns the enclosing boundaries when none match' do
          data = [1, 4, 5, 9, 10, 11, 12, 14]
          result = subject.send(:lower_and_upper_bounds, data, 9.5)
          expect(result).to eq([3, 4])
          result = subject.send(:lower_and_upper_bounds, data, 8)
          expect(result).to eq([2, 3])
          result = subject.send(:lower_and_upper_bounds, data, 13.5)
          expect(result).to eq([6, 7])
          result = subject.send(:lower_and_upper_bounds, data, 1)
          expect(result).to eq([0, 0])
        end

        it 'returns the matching boundary as the highest one when there is one' do
          data = [1, 4, 5, 9, 10, 11, 12, 14]
          result = subject.send(:lower_and_upper_bounds, data, 12.0)
          expect(result).to eq([5, 6])
          result = subject.send(:lower_and_upper_bounds, data, 12)
          expect(result).to eq([5, 6])
          result = subject.send(:lower_and_upper_bounds, data, 4)
          expect(result).to eq([0, 1])
          result = subject.send(:lower_and_upper_bounds, data, 14)
          expect(result).to eq([6, 7])
        end
      end

      describe 'closest_value' do
        it 'returns the value when both values are the same' do
          result = subject.send(:closest_value, 3, 3, 3)
          expect(result).to eq(3)
        end

        it 'returns the mean value if the values are equidistant from mean' do
          result = subject.send(:closest_value, 3, 4, 3.5)
          expect(result).to eq(3.5)
        end

        it 'returns the smaller value if it is closer to the mean' do
          result = subject.send(:closest_value, 3, 4, 3.4)
          expect(result).to eq(3)
        end

        it 'returns the larger value if it is closer to the mean' do
          result = subject.send(:closest_value, 3, 4, 3.7)
          expect(result).to eq(4)
        end
      end

      describe 'with data' do
        before do
          @data = service.steps(from, to)
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
            data = [DataEntry.new(start_date: Time.now, end_date: Time.now, values: [1, 2, 3, 4])]
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
            data = [DataEntry.new(start_date: Time.now, end_date: Time.now, values: [5, 7])]
            expected = { 4 => 1, 5 => 1, 6 => 2, 7 => 1, 8 => 1 }
            expect(subject).to receive(:max_from_hash).with(expected)
            subject.send(:soft_histogram, data, min, max, k)
          end

          describe 'should take the min into account' do
            let(:data) { [DataEntry.new(start_date: Time.now, end_date: Time.now, values:  [15, 8, 8, 8, 8])] }
            it 'should not return the 9 if 10 is min' do
              min = 10
              expected = { 14 => 1, 15 => 1, 16 => 1 }
              expect(subject).to receive(:max_from_hash).with(expected)
              subject.send(:soft_histogram, data, min, max, k)
            end

            it 'should return 9 if 9 is min (but not 8)' do
              min = 9
              expected = { 9 => 4, 14 => 1, 15 => 1, 16 => 1 }
              expect(subject).to receive(:max_from_hash).with(expected)
              subject.send(:soft_histogram, data, min, max, k)
            end
          end

          describe 'should take the max into account' do
            let(:data) { [DataEntry.new(start_date: Time.now, end_date: Time.now, values:  [5, 12, 12, 12, 12])] }
            it 'should not return the 12 if 10 is max' do
              max = 10
              expected = { 4 => 1, 5 => 1, 6 => 1 }
              expect(subject).to receive(:max_from_hash).with(expected)
              subject.send(:soft_histogram, data, min, max, k)
            end
            it 'should return 11 if 11 is max (but not 12)' do
              max = 11
              expected = { 4 => 1, 5 => 1, 6 => 1, 11 => 4 }
              expect(subject).to receive(:max_from_hash).with(expected)
              subject.send(:soft_histogram, data, min, max, k)
            end
          end

          describe 'should produce the expected result' do
            let(:data) do
              [DataEntry.new(start_date: Time.now, end_date: Time.now,
                             values: [1, 1, 1, 2, 2, 3, 4, 4, 5, 8, 10, 12, 12, 12, 66])]
            end
            let(:k) { 2 }
            let(:max) { 20 }
            it 'with a min of 5' do
              min = 5
              expected = { 5 => 4, 6 => 4, 7 => 2, 10 => 5, 11 => 4, 12 => 4, 13 => 3, 14 => 3, 8 => 2, 9 => 2 }
              expect(subject).to receive(:max_from_hash).with(expected).and_call_original
              result = subject.send(:soft_histogram, data, min, max, k)
              expect(result.first.values).to eq([10])
            end
            it 'with a min of 0' do
              min = 0
              expected = { 3 => 9, 4 => 6, 5 => 4, 6 => 4, 7 => 2, 10 => 5, 11 => 4, 12 => 4, 13 => 3, 14 => 3, 8 => 2,
                           9 => 2, 0 => 5, 1 => 6, 2 => 8 }
              expect(subject).to receive(:max_from_hash).with(expected).and_call_original
              result = subject.send(:soft_histogram, data, min, max, k)
              expect(result.first.values).to eq([3])
            end
          end
        end

        describe 'sum_values' do
          it 'should sum the values according to the buckets' do
            result = subject.send(:sum_values, @data).map(&:values)
            expected = @data.map { |x| [x.values.sum] }

            expected.zip(result) do |value, result_value|
              expect(value).to eq(result_value)
            end
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
