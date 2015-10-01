module Physiqual
  module Exporters
    class JsonExporter < Exporter
      def export(user, last_measurement_time, from, to)
        result = export_data(user, last_measurement_time, from, to)
        result.to_json
      end
    end
  end
end
