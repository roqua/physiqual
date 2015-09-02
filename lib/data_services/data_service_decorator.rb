module DataServices
  class DataServiceDecorator < SimpleDelegator
    def initialize(data_service)
      @data_service = data_service
      super
    end

    def data_service
      @data_service
    end
  end
end
