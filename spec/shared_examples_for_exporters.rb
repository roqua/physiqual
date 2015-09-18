require 'shared_context_for_exporters'

module Exporters
  shared_examples_for 'an exporter' do
    include_context 'exporter context'
    it 'should be a subclass of Exporter' do
      expect(described_class.ancestors).to include Exporter
    end

    describe 'export' do
      it 'should define an export method' do
        described_class.method_defined? :export
      end

      it 'should call the export_data method when called' do
        expect_any_instance_of(Exporter)
          .to receive(:export_data).with(user, last_measurement_time, from, to)
          .and_return(mock_result)
        subject.export(user, last_measurement_time, from, to)
      end
    end
  end
end
