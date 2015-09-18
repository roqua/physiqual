require 'rails_helper'

require 'shared_examples_for_data_services'

module DataServices
  describe FitbitService do
    include_context 'data_service context'

    let(:token) { FactoryGirl.build(:fitbit_token) }
    let(:session) { Sessions::TokenAuthorizedSession.new(token.token, FitbitToken.base_uri) }
    let(:subject) { described_class.new(session) }

    it_behaves_like 'a data_service',       steps:          'data_services/fitbit/steps',
                                            heart_rate:     'data_services/fitbit/heart_rate',
                                            sleep:          'data_services/fitbit/sleep',
                                            activities:     'data_services/fitbit/activities'

    describe 'intraday_summary' do
      it 'gets the data the data for each days' do
        # The period should contain the same number of days as below, but also include the last one (i.e. +1)
        period = (to.to_date - from.to_date).to_i + 1
        return_val = { 'activities-heart-intraday' =>
                       [{ 'value' => 123, 'dateTime' => Time.now }, { 'value' => 123, 'dateTime' => Time.now }]
        }
        expect(session).to receive(:get).exactly(period).times.and_return(return_val)
        subject.send(:intraday_summary, from, to, 'heart')
      end

      it 'should store the correct data' do
        return_val = []
        (from.to_date..to.to_date).each do |date|
          daily_values = []
          (0..23).each do |hour|
            daily_values << { 'value' => 123, 'dateTime' => date.to_time.change(hour: hour) }
          end
          return_val << { 'activities-heart-intraday' => daily_values }
        end
        expect(session).to receive(:get).and_return(*return_val)
        result = subject.send(:intraday_summary, from, to, 'heart')

        # The period should contain the same number of days as below, but also include the last one (i.e. +1)
        expect(result.count).to eq(((to.to_date - from.to_date).to_i + 1) * 24)
      end

      it 'should call the route as containing the activity, from and 1min' do
        activity = 'heart'
        period = (to.to_date - from.to_date).to_i + 1
        (from.to_date..to.to_date).each do |date|
          url = "/activities/#{activity}/date/#{date}/1d/1min.json"
          expect(session).to receive(:get).with(url).and_return("activities-#{activity}-intraday" => [123])
        end
        expect(subject).to receive(:process_entries).with([123]).exactly(period).times
        subject.send(:intraday_summary, from, to, activity)
      end
    end

    describe 'daily_summy' do
      it 'should call the route as containing the activity, from and to' do
        activity = 'heart'
        url = "/activities/#{activity}/date/#{from}/#{to}.json"
        expect(session).to receive(:get).with(url).and_return("activities-#{activity}" => [123])
        expect(subject).to receive(:process_entries).with([123])
        subject.send(:daily_summary, from, to, activity)
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
        entries = [{ datetimefield => from, valuefield => "#{integer}" }]
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

    describe 'activity_call' do
      let(:activity) { 'heart' }
      let(:from_formatted) { from.strftime(DataService::DATE_FORMAT) }
      let(:to_formatted) { to.strftime(DataService::DATE_FORMAT) }

      it 'calls intraday summary if intraday is true' do
        subject.instance_variable_set(:@intraday, true)
        expect(subject).to receive(:intraday_summary).with(from_formatted, to_formatted, activity)
        subject.send(:activity_call, from, to, activity)
      end

      it 'calls daily summary if intraday is false' do
        subject.instance_variable_set(:@intraday, false)
        expect(subject).to receive(:daily_summary).with(from_formatted, to_formatted, activity)
        subject.send(:activity_call, from, to, activity)
      end
    end
  end
end
