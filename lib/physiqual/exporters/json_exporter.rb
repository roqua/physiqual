module Physiqual
  module Exporters
    class JsonExporter < Exporter
      def export(user, first_measurement, number_of_days)
        result = export_data(user, first_measurement, number_of_days)
        result.to_json
      end
    end
  end
end
