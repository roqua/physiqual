require 'rails_helper'

require 'shared_examples_for_data_service_decorators'

module DataServices
  describe SummarizedDataService do
    it_behaves_like 'a data_service decorator'
  end
end
