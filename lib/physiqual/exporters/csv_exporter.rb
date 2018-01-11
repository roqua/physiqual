require 'csv'

module Physiqual
  module Exporters
    class CsvExporter < Exporter
      def export(user_id, first_measurement, number_of_days)
        result = export_data(user_id, first_measurement, number_of_days)
        Rails.logger.debug result

        csv_string = CSV.generate do |csv|
          csv << ['Date', result.first.second.keys].flatten
          result.each_key do |key|
            csv << [key, result[key].values].flatten
          end
        end
        csv_string
      end
    end
  end
end
