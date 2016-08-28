module Physiqual
  module DataServices
    require 'rails_helper'
    describe CassandraDataService do
      let(:subject) { described_class.new(nil, 1, nil) }
      describe 'years' do
        it 'should return blocks of years' do
          Timecop.freeze(Date.new(2016, 0o1, 0o5))
          endd = Time.now
          start = 10.days.ago - 1.year
          expected_years = [2014, 2015, 2016]
          number_of_years = expected_years.length
          froms = []
          tos = []
          subject.send(:years, start, endd) do |year, from, to|
            expect(year).to eq expected_years.shift
            froms << from
            tos << to
          end
          expect(froms.length).to eq number_of_years
          expect(tos.length).to eq number_of_years

          expect(froms.first).to eq start
          expect(froms.second).to eq Date.new(2015, 0o1, 0o1).to_time
          expect(froms.last).to eq Date.new(2016, 0o1, 0o1).to_time

          expect(tos.first).to eq Time.new(2014, 12, 31, 23, 59, 59).to_time
          expect(tos.second).to eq Time.new(2015, 12, 31, 23, 59, 59).to_time
          expect(tos.last).to eq endd
          Timecop.return
        end

        it 'should only return one year if there is no year shift in between' do
          Timecop.freeze(Date.new(2016, 0o1, 25))
          endd = Time.now
          start = 10.days.ago
          expected_years = [2016]
          number_of_years = expected_years.length
          froms = []
          tos = []
          subject.send(:years, start, endd) do |year, from, to|
            expect(year).to eq expected_years.shift
            froms << from
            tos << to
          end
          expect(froms.length).to eq number_of_years
          expect(tos.length).to eq number_of_years

          expect(froms.first).to eq start
          expect(tos.last).to eq endd
        end
      end

      describe 'cache_data' do
        let(:start_date) { Time.new(2014, 12, 31, 23, 56, 0) }
        let(:end_date) { Time.new(2014, 12, 31, 23, 57, 0) }
        let(:user_id) { 1 }
        let(:variable) { 'some_variable' }
        it 'should call sidekick asynchronously' do
          expect(Sidekiq::Status).to receive(:queued?).and_return(false)
          expect(Sidekiq::Status).to receive(:working?).and_return(false)

          expect(Physiqual::Workers::CacheWorker).to receive(:perform_async)
            .with(subject.data_service, subject, variable, user_id, start_date, end_date)
            .and_return(true)
          subject.send(:cache_data, variable, user_id, start_date, end_date)
        end
      end

      describe 'make_data_enries' do
        let(:results) do
          [
            {
              'value' => '10',
              'start_date' => Time.new(2014, 12, 31, 23, 56, 0),
              'end_date' => Time.new(2014, 12, 31, 23, 57, 0),
              'time' => Time.new(2014, 12, 31, 23, 56, 30)
            },
            {
              'value' => '42',
              'start_date' => Time.new(2014, 12, 31, 23, 57, 0),
              'end_date' => Time.new(2014, 12, 31, 23, 58, 0),
              'time' => Time.new(2014, 12, 31, 23, 57, 30)
            },
            {
              'value' => '1',
              'start_date' => Time.new(2014, 12, 31, 23, 58, 0),
              'end_date' => Time.new(2014, 12, 31, 23, 59, 0),
              'time' => Time.new(2014, 12, 31, 23, 58, 30)
            }
          ]
        end
        it 'should return [] if there are no results' do
          expect(subject.send(:make_data_entries, 'variable', nil)).to eq []
          expect(subject.send(:make_data_entries, 'variable', [])).to eq []
        end

        it 'should transform the value of a result to int if it is not activity' do
          result = subject.send(:make_data_entries, 'variable', results)
          expect(result.length).to eq 3
          zipped = result.zip(results)
          zipped.each do |res, expected|
            expect(res.start_date).to eq expected['start_date']
            expect(res.end_date).to eq expected['end_date']
            expect(res.measurement_moment).to eq expected['time']
            expect(res.values).to be_an Array
            expect(res.values.first).to be_an Integer
            expect(res.values.first).to eq expected['value'].to_i
          end
        end

        it 'should not transform the value of a result to int if it is not activity' do
          result = subject.send(:make_data_entries, 'activities', results)
          zipped = result.zip(results)
          zipped.each do |res, expected|
            expect(res.values).to be_an Array
            expect(res.values.first).to be_a String
            expect(res.values.first).to eq expected['value']
          end
        end
      end
    end
  end
end
