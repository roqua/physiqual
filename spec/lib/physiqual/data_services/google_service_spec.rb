module Physiqual
  require 'rails_helper'

  require 'shared_examples_for_data_services'

  module DataServices
    describe GoogleService do
      include_context 'data_service context'

      let(:token) { FactoryGirl.build(:google_token) }
      let(:session) { Sessions::TokenAuthorizedSession.new(token) }
      let(:subject) { described_class.new(session) }

      it_behaves_like 'a data_service',       steps:          'data_services/google/steps',
                                              heart_rate:     'data_services/google/heart_rate',
                                              sleep:          'data_services/google/sleep',
                                              distance:       'data_services/google/distance',
                                              activities:     'data_services/google/activities',
                                              calories:       'data_services/google/calories'
    end
  end
end
