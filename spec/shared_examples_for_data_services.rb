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

  shared_context 'data_service context' do
    def check_result_format(result)
      expect(result).to be_a Array
      result.each do |entry|
        expect(entry).to be_a Hash
        expect(entry.keys.length).to eq 2
        expect(entry.keys).to include DataService.new.date_time_field
        expect(entry.keys).to include DataService.new.values_field
        expect(entry[DataService.new.values_field]).to be_a Array
        expect(entry[DataService.new.date_time_field]).to be_a Time
      end
    end

    def check_start_end_date(result, from, to)
      dates = result.map { |x| x[DataService.new.date_time_field] }
      lowest_date = dates.min
      highest_date = dates.max
      expect(lowest_date).to be_between(from, to)
      expect(highest_date).to be_between(from, to)
    end
  end
end
