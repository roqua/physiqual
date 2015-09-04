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
  end
end
