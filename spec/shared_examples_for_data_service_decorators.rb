module DataServices
  shared_examples_for 'a data_service decorator' do
    let(:service) { MockFitbitService.new}
    let(:instance) { described_class.new(service) }
    it 'should define the extended methods funcion' do
      expect(instance.service_name).to_not eq DataService.new.service_name
    end
  end
end
