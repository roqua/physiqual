module Physiqual
  require 'rails_helper'
  require 'shared_examples_for_exporters'
  require 'shared_context_for_exporters'

  module Exporters
    describe CsvExporter do
      it_behaves_like 'an exporter'
      include_context 'exporter context'

      describe 'export' do
        before do
          allow_any_instance_of(Exporter)
            .to receive(:export_data).with(user, first_measurement, number_of_days)
                                     .and_return(mock_result)

          @result = subject.export(user, first_measurement, number_of_days)
        end

        it 'should respond with CSV' do
          expect(csv?(@result)).to be_truthy
        end

        it 'should have the correct header' do
          expect(@result).to include('Date')
          mock_result.first.second.each_key do |key|
            expect(@result).to include(key.to_s)
          end
        end
      end

      # TODO: Implement correct check whether the result is valid CSV
      def csv?(csv)
        valid = csv.include?(';')
        valid |= csv.include?(',')
        valid &= csv.include?("\n")
        valid
      end
    end
  end
end
