require 'rails_helper'

require 'shared_examples_for_data_services'

module DataServices
  describe FitbitService do
    it_behaves_like 'a data_service'
  end
end
