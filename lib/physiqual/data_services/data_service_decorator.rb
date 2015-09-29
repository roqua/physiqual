module Physiqual
  module DataServices
    class DataServiceDecorator < DelegateClass(DataService)
      delegate :output_entry, to: :__getobj__
      def data_service
        __getobj__
      end
    end
  end
end
