module Physiqual
  module Exporters
    class JsonExporter < Exporter
      def export(user, first_measurement, number_of_days)
        export_data(user, first_measurement, number_of_days).to_json
      end
    end
  end
end
