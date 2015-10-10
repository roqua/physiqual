module Physiqual
  module BucketGenerators
    shared_context 'bucket_generator context' do
      let(:from) { Time.new(2015, 7, 4, 3, 0).in_time_zone }
      let(:to) { Time.new(2015, 8, 4, 21, 0).in_time_zone }
      def check_result_format(result)
        expect(result).to be_a Array
        result.each do |entry|
          expect(entry).to be_a Hash
          expect(entry.keys.length).to eq 3
          expect(entry.keys).to include Physiqual::DataServices::DataService.new.date_time_field
          expect(entry.keys).to include Physiqual::DataServices::DataService.new.date_time_start_field
          expect(entry.keys).to include Physiqual::DataServices::DataService.new.values_field
          expect(entry[Physiqual::DataServices::DataService.new.date_time_field]).to be_a ActiveSupport::TimeWithZone
          expect(entry[Physiqual::DataServices::DataService.new.date_time_start_field]).to be_a ActiveSupport::TimeWithZone
          expect(entry[Physiqual::DataServices::DataService.new.values_field]).to be_a Array
          expect(entry[Physiqual::DataServices::DataService.new.values_field].any? { |x| x.is_a? Array }).to be_falsey
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
