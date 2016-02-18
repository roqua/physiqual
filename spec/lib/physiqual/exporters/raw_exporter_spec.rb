module Physiqual
  require 'rails_helper'
  require 'shared_examples_for_exporters'
  require 'shared_context_for_exporters'

  module Exporters
    describe RawExporter do
      # it_behaves_like 'an exporter' # doesn't work since we override stuff. moved tests here.
      include_context 'exporter context'

      describe 'export' do
        before do
          expect_any_instance_of(RawExporter)
            .to receive(:export_data).with(user, first_measurement, number_of_days)
            .and_return(mock_result)
        end

        it 'should respond with JSON' do
          result = subject.export(user, first_measurement, number_of_days)
          expect(json?(result)).to be_truthy
        end
      end

      it 'should be a subclass of Exporter' do
        expect(described_class.ancestors).to include Exporter
      end

      def json?(json)
        # rubocop:disable Style/DoubleNegation
        !!JSON.parse(json)
        # rubocop:enable Style/DoubleNegation
      rescue
        false
      end
    end
  end
end
