require 'rails_helper'

require 'shared_examples_for_data_services'
require 'shared_context_for_data_services'

module DataServices
  describe SummarizedDataService do
    # TODO: This should be figured out, how does it work to have a decorator pattern where one of the classes
    # also receives some other things during initialization

    let(:last_measurement_time) { Time.now.change(hour: 22, min: 30) }
    let(:interval) { 6 }
    let(:measurements_per_day) { 3 }
    let(:service) { MockService.new(nil) }
    let(:subject) do
      SummarizedDataService.new(service,
                                last_measurement_time,
                                measurements_per_day,
                                interval, true)
    end

    it_behaves_like 'a data_service'
    include_context 'data_service context'

    describe 'generate_buckets' do
      it 'should output the correct format' do
        @result = subject.send(:generate_buckets, from, to)
        check_result_format(@result)
      end
    end

    describe 'cluster_in_buckets' do
      it 'should output the correct format' do
        data = service.steps(from, to)
        @result = subject.send(:cluster_in_buckets, data, from, to)
        check_result_format(@result)
      end
    end

    describe 'with generated buckets' do
      before do
        @data = service.steps(from, to)
        @data = subject.send(:cluster_in_buckets, @data, from, to)
      end

      after(:each) do
        check_result_format(@result)
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
          offset = 0
          max = 300
          k = 2
          @result = subject.send(:soft_histogram, @data, offset, max, k)
        end
      end
    end
  end
end
