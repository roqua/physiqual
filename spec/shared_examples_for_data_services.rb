module DataServices
  shared_examples_for 'a data_service' do
    let(:token) { FactoryGirl.create(:google_token) }
    let(:instance) { described_class.new(token) }
    it 'should define the extended methods funcion' do
      expect(instance.service_name).to_not eq DataService.new.service_name
    end
    it 'initializes without HTTParty, should be injected' do
      expect(described_class.ancestors).to_not include HTTParty
    end
  end
end
