class DataServiceDecorator < DataService
  def initialzie(data_service)
    @data_service = data_service
  end
end
