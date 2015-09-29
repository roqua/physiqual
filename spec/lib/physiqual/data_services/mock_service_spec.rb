module Physiqual
  require 'rails_helper'
  
  require 'shared_examples_for_data_services'
  
  module DataServices
    describe MockService do
      include_context 'data_service context'
  
      let(:subject) { described_class.new(nil) }
  
      it_behaves_like 'a data_service'
    end
  end
end
