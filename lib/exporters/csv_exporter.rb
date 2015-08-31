module Exporters
  class CsvExporter < Exporter
    def export(user, last_measurement_time, from, to)
      result = export_me(user, last_measurement_time, from, to)

      csv_string = CSV.generate do |csv|
        csv << ['Date', result.first.second.keys].flatten
        result.keys.each do |key|
          csv << [key, result[key].values].flatten
        end
      end
      csv_string
    end
  end
end
