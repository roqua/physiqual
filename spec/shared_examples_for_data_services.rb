module DataServices
  shared_examples_for 'a data_service' do
    let(:token) { FactoryGirl.create(:google_token) }
    let(:instance) { described_class.new(token) }
    it 'should define the extended methods funcion' do
      expect(instance.service_name).to_not eq DataService.new.service_name
      it 'initializes with HTTParty' do
        expect(described_class.ancestors).to include HTTParty
      end
    end
  end
end
