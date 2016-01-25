module Physiqual
  require 'rails_helper'

  require 'shared_examples_for_data_services'
  require 'shared_context_for_data_services'

  module DataServices
    describe BucketeerDataService do
      let(:last_measurement_time) { Time.now.change(hour: 22, min: 30, usec: 0) }
      let(:interval) { 6 }
      let(:measurements_per_day) { 3 }
      let(:hours_before_first_measurement) { 12 } # previously: use_night == true
      let(:service) { MockService.new(nil) }
      let(:bucket_generator_without_night) do
        BucketGenerators::EquidistantBucketGenerator.new(
          measurements_per_day,
          interval,
          interval)
      end
      let(:bucket_generator_with_night) do
        BucketGenerators::EquidistantBucketGenerator.new(
          measurements_per_day,
          interval,
          hours_before_first_measurement)
      end

      let(:subject) { BucketeerDataService.new(service, bucket_generator_without_night) }

      it_behaves_like 'a data_service'
      include_context 'data_service context'

      describe 'cluster_in_buckets' do
        let(:data) { service.steps(from, to) }
        let(:from_subset) { (to - 1.day).change(hour: 10, min: 30) - interval.hours }
        let(:to_subset) { (to - 1.day).change(hour: 22, min: 30) }
        let(:data_subset) { data.select! { |x| x.measurement_moment.to_date == from_subset.to_date } }

        it 'should output the correct format' do
          @result = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
          check_result_format(@result)
        end

        it 'should correctly cluster the data into buckets' do
          res = []
          (0...measurements_per_day).each do |meas|
            beginn = from_subset + (meas * interval).hours
            endd = from_subset + ((meas + 1) * interval).hours
            res << data.select { |x| x.measurement_moment <= endd && x.measurement_moment > beginn }
          end

          full_result = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
          res.each_with_index do |current_res, index|
            # The results can be sorted, as the order in the values does not matter
            expected = current_res.map(&:values).flatten.sort
            result = full_result[index].values.sort
            expect(result.size).to eq expected.size
            expect(result).to eq expected
          end
        end

        describe 'should take the night flag into account' do
          before do
            subject = BucketeerDataService.new(service, bucket_generator_with_night)
            full_with_night = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
            @full_with_night = full_with_night.first.values.sort

            subject = BucketeerDataService.new(service, bucket_generator_without_night)
            full_without_night = subject.send(:cluster_in_buckets, data, from_subset, to_subset)
            @full_without_night = full_without_night.first.values.sort
          end

          # Should have more elements
          it { expect(@full_with_night.size).to be > @full_without_night.length }

          # Should be a superset
          it { expect(@full_without_night - @full_with_night).to be_blank }
        end
      end
    end
  end
end
