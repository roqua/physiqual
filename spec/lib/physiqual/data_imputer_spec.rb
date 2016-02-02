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
    fdescribe 'supported formats' do
      it 'calls the data service correctly' do
        meths = [:steps, :heart_rate, :distance, :sleep, :calories, :activities]
        to = Time.zone.now
        from = to - 60.minutes
        expect(imputers[0]).to receive(:impute!).with([1, 2, 3, nil]).and_return([1, 2, 3, 4])
        expect(imputers[1]).to_not receive(:impute!)
        expect(imputers[2]).to_not receive(:impute!)
        meths.each do |meth|
          expect(data_service).to receive(meth).once.with(from, to).and_call_original
          instance = described_class.new data_service, imputers
          #expect(instance).to receive(:impute_results).once.and_call_original
          instance.send(meth, from, to)
        end
      end
    end
    describe '#impute_results' do
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
  end
end