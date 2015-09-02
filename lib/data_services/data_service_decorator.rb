module DataServices
  class DataServiceDecorator < SimpleDelegator
    def initialize(data_service)
      @data_service = data_service
      super
    end

    attr_reader :data_service
  end
end
