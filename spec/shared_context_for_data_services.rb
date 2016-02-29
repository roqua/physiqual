module Physiqual
  module DataServices
    shared_context 'data_service context' do
      let(:from) { Time.new(2015, 7, 4, 0, 0).in_time_zone }
      let(:to) { Time.new(2015, 8, 4, 0, 0).in_time_zone }
      def check_result_format(result)
        expect(result).to be_a Array
        return true if result.nil?
        result.each do |entry|
          expect(entry).to be_a DataEntry
          expect(entry.start_date).to be_a Time
          expect(entry.end_date).to be_a Time
          expect(entry.measurement_moment).to be_a Time
          expect(entry.values).to be_a Array
          expect(entry.values.any? { |x| x.is_a? Array }).to be_falsey
        end
      end

      def check_start_end_date(result, from, to)
        dates = result.map(&:measurement_moment)
        lowest_date = dates.min
        highest_date = dates.max
        expect(lowest_date).to be_between(from.beginning_of_day, to.end_of_day)
        expect(highest_date).to be_between(from.beginning_of_day, to.end_of_day)
      end
    end
  end
end
