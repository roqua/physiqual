module Physiqual
  require 'rails_helper'
  describe DataImputer do
    let(:imputers) do
      [
        instance_double('Imputer 1'),
        instance_double('Imputer 2'),
        instance_double('Imputer 3')
      ]
    end
    let(:data_service) { DataServices::MockService.new(nil) }
    describe 'supported formats' do
      it 'calls the data service correctly' do
        meths = [:steps, :heart_rate, :distance, :sleep, :calories, :activities]
        to = Time.zone.now
        from = to - 40.minutes
        data_service.instance_variable_set(:@measurements, [1, 2, 3, nil])
        expect(imputers[0]).to receive(:impute!).with([1, 2, 3, nil]).and_return([1, 2, 3, 4])
          .exactly(meths.length).times
        expect(imputers[1]).to_not receive(:impute!)
        expect(imputers[2]).to_not receive(:impute!)
        meths.each do |meth|
          expect(data_service).to receive(meth).once.with(from, to).and_call_original
          instance = described_class.new data_service, imputers
          expect(instance).to receive(:impute_results).once.and_call_original
          instance.send(meth, from, to)
        end
      end
    end
    describe '#impute_results' do
      it 'Runs the impute function on all provided imputers' do
        to_impute = [1, 2, 3, nil]
        imputers.each { |imp| expect(imp).to receive(:impute!).once { to_impute } }

        instance = described_class.new 'services', imputers

        data = []
        to_impute.each_with_index do |value, index|
          data << DataEntry.new(start_date: index - 1,
                                end_date: index,
                                measurement_moment: index - 0.5,
                                values: [value])
        end

        instance.send(:impute_results, data)
      end

      it 'Changes the values of the result according to the result of the imputers' do
        to_impute = [1, 2, 3, nil]
        imputers.each { |imp| expect(imp).to receive(:impute!).once { [1, 2, nil, 4] } }

        instance = described_class.new 'services', imputers
        data = []
        to_impute.each_with_index do |value, index|
          data << DataEntry.new(start_date: index - 1,
                                end_date: index,
                                measurement_moment: index - 0.5,
                                values: [value])
        end

        result = instance.send(:impute_results, data)
        expect(result.values).to eq([1, 2, nil, 4])
      end

      it 'only reimputes missing values' do
        to_impute = [1, nil, nil, nil]
        expect(imputers[0]).to receive(:impute!).with(to_impute).once { [1, 2, nil, nil] }
        expect(imputers[1]).to receive(:impute!).with([1, 2, nil, nil]).once { [1, 2, 3, nil] }
        expect(imputers[2]).to receive(:impute!).with([1, 2, 3, nil]).once { [1, 2, 3, 4] }

        data = []
        to_impute.each_with_index do |value, index|
          data << DataEntry.new(start_date: DateTime.new(index),
                                end_date: DateTime.new(index + 1),
                                measurement_moment: DateTime.new(index + 0.5),
                                values: [value])
        end

        @instance = described_class.new 'services', imputers
        result = @instance.send(:impute_results, data)
        expect(result).to eq(DateTime.new(1) => 1, DateTime.new(2) => 2,
                             DateTime.new(3) => 3, DateTime.new(4) => 4)
      end
    end

    describe '#retrieve_data_from_service' do
      it 'is not publicly defined' do
        expect(described_class.new('service', 'imputers')).to_not respond_to :retrieve_data_from_service
      end

      it 'runs a function for the services' do
        service = 'service'
        instance = described_class.new service, 'imputers'
        service_result = []
        instance.send(:retrieve_data_from_service) { |serv| service_result << serv }
        expect(service_result).to eq [service]
      end

      it 'fails with a message if no services are defined' do
        instance = described_class.new nil, 'imputers'
        expect { instance.send(:retrieve_data_from_service) }.to raise_error 'No service defined'
      end

      describe 'can deal with a service that might not define the function' do
        let(:service_obj) { double('Service') }
        let(:result) { 'Called Service' }
        let(:msg) { 'warn msg' }
        let(:instance) { described_class.new service_obj, 'imputers' }

        it 'does not raise an error' do
          allow(service_obj).to receive(:defined_method).and_return('test')
          expect { instance.send(:retrieve_data_from_service, &:defined_method) }.to_not raise_error
        end

        it 'logs the message' do
          expect(service_obj).to receive(:not_defined_method).and_raise(Errors::NotSupportedError, msg).once
          expect(Rails.logger).to receive(:warn).with(msg)
          expect(instance.send(:retrieve_data_from_service, &:not_defined_method)).to eq nil
        end
      end
    end
  end
end
