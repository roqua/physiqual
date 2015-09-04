module Exporters
  class JsonExporter < Exporter
    def export(user, last_measurement_time, from, to)
      result = export_me(user, last_measurement_time, from, to)
      result.to_json
    end
  end
end
