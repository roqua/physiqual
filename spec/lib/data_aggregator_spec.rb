require 'rails_helper'
describe DataAggregator do
  describe '#initializer' do
  end

  describe 'Datafunctions' do
  end

  describe '#run_function' do
  end

  describe '#impute_result' do
    let(:imputers) do
      [
        instance_double('Imputer 1'),
        instance_double('Imputer 2'),
        instance_double('Imputer 3')
      ]
    end

    it 'Runs the impute function on all provided imputers' do
      imputers.each { |imp| expect(imp).to receive(:impute!).once { [1, 2, 3, nil] } }

      instance = described_class.new 'services', imputers
      instance.send(:impute_results, 1 => 1, 2 => 2, 3 => 3, 4 => nil)
    end

    it 'Changes the values of the result according to the result of the imputers' do
      imputers.each { |imp| expect(imp).to receive(:impute!).once { [1, 2, nil, 4] } }

      instance = described_class.new 'services', imputers
      result = instance.send(:impute_results, 1 => 1, 2 => 2, 3 => 3, 4 => nil)
      expect(result).to eq(1 => 1, 2 => 2, 3 => nil, 4 => 4)
    end

    it 'only runs part of the imputers if no missing values remain' do
      expect(imputers[0]).to receive(:impute!).with([1, 2, 3, nil]).once { [1, 2, 3, 4] }
      expect(imputers[1]).to_not receive(:impute!)
      expect(imputers[2]).to_not receive(:impute!)

      instance = described_class.new 'services', imputers
      result = instance.send(:impute_results, 1 => 1, 2 => 2, 3 => 3, 4 => nil)
      expect(result).to eq(1 => 1, 2 => 2, 3 => 3, 4 => 4)
    end

    it 'only reimputes missing values' do
      expect(imputers[0]).to receive(:impute!).with([1, nil, nil, nil]).once { [1, 2, nil, nil] }
      expect(imputers[1]).to receive(:impute!).with([1, 2, nil, nil]).once { [1, 2, 3, nil] }
      expect(imputers[2]).to receive(:impute!).with([1, 2, 3, nil]).once { [1, 2, 3, 4] }

      @instance = described_class.new 'services', imputers
      result = @instance.send(:impute_results, 1 => 1, 2 => nil, 3 => nil, 4 => nil)
      expect(result).to eq(1 => 1, 2 => 2, 3 => 3, 4 => 4)
    end
  end

  describe '#retrieve_data_of_all_services' do
    it 'is not publicly defined' do
      expect(described_class.new 'services', 'imputers').to_not respond_to :retrieve_data_of_all_services
    end

    it 'runs a function for all services' do
      services = %w(service1 service2 service3)
      instance = described_class.new services, 'imputers'
      services_result = []
      instance.send(:retrieve_data_of_all_services) { |serv| services_result << serv }
      expect(services_result).to eq services
    end

    it 'fails with a message if no services are defined' do
      _instance = described_class.new [nil, nil, nil], 'imputers'
      # expect(instance.send(:retrieve_data_of_all_services) { |serv| serv}).to raise_error
    end
  end
end
