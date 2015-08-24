class DataServiceDecorator < DataService
  def initialize(data_service)
    @data_service = data_service
  end

  protected

  attr_reader :data_service
end
