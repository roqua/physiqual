require 'rails_helper'

require 'shared_examples_for_data_services'

module DataServices
  describe FitbitService do
    it_behaves_like 'a data_service'
    include_context 'data_service context'

    let(:from) { Time.new(2015, 7, 4, 0, 0).in_time_zone }
    let(:to) { Time.new(2015, 8, 4, 0, 0).in_time_zone }
    let(:token) { FactoryGirl.build(:fitbit_token) }

    let(:session) { Sessions::TokenAuthorizedSession.new(token.token, FitbitToken.base_uri) }
    let(:subject) { described_class.new(session) }

    describe 'steps' do
      before do
        VCR.use_cassette('data_services/fitbit/steps') do
          @result = subject.steps(from, to)
        end
      end

      it 'returns the steps in the correct format' do
        check_result_format(@result)
      end

      it 'gets the steps from the correct date till the correct date' do
        check_start_end_date(@result, from, to)
      end
    end
  end
end
