shared_examples_for 'a data_service' do
  let(:token) { FactoryGirl.create(:google_token) }
  let(:instance) { described_class.new(token) }
  it 'should define an impute! funcion' do
    expect(instance.methods).to include :steps
    expect(instance.methods).to include :heart_rate
  end
end
