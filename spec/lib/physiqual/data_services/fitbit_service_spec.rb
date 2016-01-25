module Physiqual
  require 'rails_helper'

  require 'shared_examples_for_data_services'

  module DataServices
    describe FitbitService do
      include_context 'data_service context'

      let(:token) { FactoryGirl.build(:fitbit_token) }
      let(:session) { Sessions::TokenAuthorizedSession.new(token) }
      let(:subject) { described_class.new(session) }
      let(:time_format) { '%I:%M%p' }
      before { subject.instance_variable_set(:@intraday, true) }
      it_behaves_like 'a data_service',
                      steps:          'data_services/fitbit/steps',
                      heart_rate:     'data_services/fitbit/heart_rate',
                      sleep:          'data_services/fitbit/sleep',
                      distance:       'data_services/fitbit/distance',
                      activities:     'data_services/fitbit/activities',
                      calories:       'data_services/fitbit/calories'

      describe 'intraday_summary' do
        it 'should have the intraday variable defined' do
          intraday_variable = subject.instance_variable_get(:@intraday)
          # it should be either true or false
          result = intraday_variable == true || intraday_variable == false
          expect(result).to be_truthy
        end

        it 'gets the data the data for each days' do
          subject.instance_variable_set(:@intraday, false)
          # The period should contain the same number of days as below, but also include the last one (i.e. +1)
          period = (to.to_date - from.to_date).to_i + 1
          return_val = { 'activities-heart-intraday' => {
            'dataset' => [
              { 'value' => 123, 'time' => Time.now.strftime(time_format) },
              { 'value' => 123, 'time' => Time.now.strftime(time_format) }
            ]
          }
          }
          expect(session).to receive(:get).exactly(period).times.and_return(return_val)
          subject.send(:intraday_summary, from, to, 'activities', 'heart')
        end

        it 'should store the correct data' do
          subject.instance_variable_set(:@intraday, false)
          return_val = []
          (from.to_date..to.to_date).each do |date|
            daily_values = []
            (0..23).each do |hour|
              daily_values << { 'value' => 123, 'time' => date.to_time.change(hour: hour).strftime(time_format) }
            end
            return_val << { 'activities-heart-intraday' => { 'dataset' => daily_values } }
          end
          expect(session).to receive(:get).and_return(*return_val)
          result = subject.send(:intraday_summary, from, to, 'activities', 'heart')

          # The period should contain the same number of days as below, but also include the last one (i.e. +1)
          expect(result.count).to eq(((to.to_date - from.to_date).to_i + 1) * 24)
        end

        it 'should call the route as containing the activity, from and 1min' do
          subject.instance_variable_set(:@intraday, true)
          resource = 'activities'
          activity = 'heart'
          (from.to_date..to.to_date).each do |date|
            url = "/#{resource}/#{activity}/date/#{date}/1d/1min.json"
            expect(session).to receive(:get).with(url).and_return("#{resource}-#{activity}-intraday" =>
                                                                  { 'datasource' => [123] })
            expect(subject).to receive(:process_intraday_entries).with({ 'datasource' => [123] }, date).exactly(1).times
          end
          subject.send(:intraday_summary, from, to, resource, activity)
        end
      end

      describe 'daily_summy' do
        it 'should call the route as containing the activity, from and to' do
          resource = 'activities'
          activity = 'heart'
          url = "/#{resource}/#{activity}/date/#{from}/#{to}.json"
          expect(session).to receive(:get).with(url).and_return("#{resource}-#{activity}" => [123])
          expect(subject).to receive(:process_entries).with([123])
          subject.send(:daily_summary, from, to, resource, activity)
        end
      end

      describe 'process_entries' do
        let(:datetimefield) { 'dateTime' }
        let(:valuefield) { 'value' }
        it 'processes entries from the fitbit service' do
          entries = [{ datetimefield => from, valuefield => 132 },
                     { datetimefield => from, valuefield => 132 },
                     { datetimefield => from, valuefield => 132 }]
          result = subject.send(:process_entries, entries)

          expected = [{ subject.date_time_field => from, subject.values_field => [132] },
                      { subject.date_time_field =>  from, subject.values_field => [132] },
                      { subject.date_time_field =>  from, subject.values_field => [132] }]
          expect(result).to eq expected
        end

        it 'converts convertable strings to ints' do
          integer = 123
          entries = [{ datetimefield => from, valuefield => integer.to_s }]
          result = subject.send(:process_entries, entries)
          expected = [{ subject.date_time_field => from, subject.values_field => [integer] }]

          expect(result).to eq expected
        end

        it 'converts non-convertable strings not to ints' do
          teststring = 'test-string'
          entries = [{ datetimefield => from, valuefield => teststring }]
          result = subject.send(:process_entries, entries)
          expected = [{ subject.date_time_field => from, subject.values_field => [teststring] }]

          expect(result).to eq expected
        end
      end

      describe 'process_intraday_entries' do
        before :each do
          date = from.to_date
          dataset = { 'dataset' => [{ 'time' => '00:00:00', 'value' => 0 },
                                    { 'time' => '00:01:00', 'value' => 1 },
                                    { 'time' => '00:02:00', 'value' => 2 }] }
          @result = subject.send(:process_intraday_entries, dataset, date)
          expect(@result.length).to eq 3
        end

        it 'should return the correct date' do
          expected_format = '%Y-%m-%d'
          @result.each do |entry|
            result = entry[subject.date_time_field].strftime(expected_format).to_s
            expect(result).to match(/[0-9]{4}-[0-9]{2}-[0-9]{2}/)
            expect(result).to eq from.to_date.strftime(expected_format)
          end
        end

        it 'should return the correct time' do
          expected_format = '%H:%M:%S'
          expected_times = %w(00:00:00 00:01:00 00:02:00)
          @result.each_with_index do |entry, idx|
            result = entry[subject.date_time_field].strftime(expected_format).to_s
            expect(result).to match(/[0-9]{2}:[0-9]{2}:[0-9]{2}/)
            expect(result).to eq expected_times[idx]
          end
        end
      end

      describe 'activity_call' do
        let(:activity) { 'heart' }
        let(:resource) { 'activities' }
        let(:from_formatted) { from.strftime(DataService::DATE_FORMAT) }
        let(:to_formatted) { to.strftime(DataService::DATE_FORMAT) }

        it 'calls intraday summary if intraday is true' do
          subject.instance_variable_set(:@intraday, true)
          expect(subject).to receive(:intraday_summary).with(from_formatted, to_formatted, resource, activity)
          subject.send(:activity_call, from, to, resource, activity)
        end

        it 'calls daily summary if intraday is false' do
          subject.instance_variable_set(:@intraday, false)
          expect(subject).to receive(:daily_summary).with(from_formatted, to_formatted, resource, activity)
          subject.send(:activity_call, from, to, resource, activity)
        end
      end
    end
  end
end
