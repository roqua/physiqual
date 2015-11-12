module Physiqual
  module DataServices
    shared_context 'data_service context' do
      let(:from) { Time.new(2015, 7, 4, 0, 0).in_time_zone }
      let(:to) { Time.new(2015, 8, 4, 0, 0).in_time_zone }
      def check_result_format(result)
        expect(result).to be_a Array
        return true if result.nil?
        result.each do |entry|
          expect(entry).to be_a Hash
          expect(entry.keys.length).to eq 2
          expect(entry.keys).to include DataService.new.date_time_field
          expect(entry.keys).to include DataService.new.values_field
          expect(entry[DataService.new.date_time_field]).to be_a Time
          expect(entry[DataService.new.values_field]).to be_a Array
          expect(entry[DataService.new.values_field].any? { |x| x.is_a? Array }).to be_falsey
        end
      end

      def check_start_end_date(result, from, to)
        dates = result.map { |x| x[DataService.new.date_time_field] }
        lowest_date = dates.min
        highest_date = dates.max
        expect(lowest_date).to be_between(from.beginning_of_day, to.end_of_day)
        expect(highest_date).to be_between(from.beginning_of_day, to.end_of_day)
      end
    end
  end
end
