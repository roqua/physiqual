module Physiqual
  module Exporters
    class CsvExporter < Exporter
      def export(user, last_measurement_time, from, to)
        result = export_data(user, last_measurement_time, from, to)
        Rails.logger.debug result
  
        csv_string = CSV.generate do |csv|
          csv << ['Date', result.first.second.keys].flatten
          Rails.logger.debug csv
          result.keys.each do |key|
            csv << [key, result[key].values].flatten
          end
        end
        csv_string
      end
    end
  end
end
