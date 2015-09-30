module Physiqual
  require 'rails_helper'
  require 'shared_examples_for_exporters'
  require 'shared_context_for_exporters'

  module Exporters
    describe JsonExporter do
      it_behaves_like 'an exporter'
      include_context 'exporter context'

      describe 'export' do
        before do
          allow_any_instance_of(Exporter)
            .to receive(:export_data).with(user, last_measurement_time, from, to)
            .and_return(mock_result)
        end

        it 'should respond with JSON' do
          result = subject.export(user, last_measurement_time, from, to)
          expect(json? result).to be_truthy
        end
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
