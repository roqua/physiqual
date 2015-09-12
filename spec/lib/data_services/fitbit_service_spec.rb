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
        return_val = {'activities-heart-intraday'=>[{'value'=>123, 'dateTime'=> Time.now}, {'value'=>123, 'dateTime'=> Time.now}]}
        expect(session).to receive(:get).exactly(period).times.and_return(return_val)
        subject.send(:intraday_summary, from, to, 'heart')
      end

      it 'should store the correct data', focus: true do
        return_val = []
        (from.to_date..to.to_date).each do |date|
          (1..24).do |hour|
          return_val << {'activities-heart-intraday'=>[{'value'=>123, 'dateTime'=> date.to_time}, {'value'=>123, 'dateTime'=> Time.now}]}
        end
        expect(session).to receive(:get).and_return(return_val)
        puts subject.send(:intraday_summary, from, to, 'heart')
      end
    end

    describe 'daily_summy' do

    end

    describe 'process_entries' do

    end
  end
end
