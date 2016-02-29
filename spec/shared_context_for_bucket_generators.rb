module Physiqual
  module BucketGenerators
    shared_context 'bucket_generator context' do
      let(:from) { Time.new(2015, 7, 4, 3, 0).in_time_zone }
      let(:to) { Time.new(2015, 8, 4, 21, 0).in_time_zone }
      def check_result_format(result)
        expect(result).to be_a Array
        result.each do |entry|
          expect(entry).to be_a DataEntry
          expect(entry.start_date).to be_a ActiveSupport::TimeWithZone
          expect(entry.end_date).to be_a ActiveSupport::TimeWithZone
          expect(entry.measurement_moment).to be_a ActiveSupport::TimeWithZone
          expect(entry.values).to be_a Array
          expect(entry.values.any? { |x| x.is_a? Array }).to be_falsey
        end
      end

      def check_start_end_date(result, from, to)
        dates = result.map { |x| x[Physiqual::DataServices::DataService.new.date_time_field] }
        lowest_date = dates.min
        highest_date = dates.max
        expect(lowest_date).to be_between(from.beginning_of_day, to.end_of_day)
        expect(highest_date).to be_between(from.beginning_of_day, to.end_of_day)
      end
    end
  end
end
