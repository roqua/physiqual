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
    end

    describe 'daily_summy' do
    end

    describe 'process_entries' do
    end
  end
end
