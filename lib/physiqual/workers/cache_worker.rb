require 'sidekiq'

module Physiqual
  module Workers
    class CacheWorker
      include Sidekiq::Worker

      def perform(data_service, cassandra_dataservice, variable, user_id, from, to)
        @user_id = user_id
        @data_service = data_service

        connection = CassandraConnection.instance

        #  Sidekiq converts all dates to strings, so we have to parse them back to dates,
        from = Time.zone.parse(from) if from.is_a? String
        to = Time.zone.parse(to) if to.is_a? String
        store_data(connection, cassandra_dataservice, variable, from, to)
      end

      private

      def store_data(connection, cassandra_dataservice, table, from, to)
        entries = cassandra_dataservice.get_data(connection, @user_id, table, from, to)
        # Retrieve the function to use for getting the data
        data_service_function = get_data_function(table)

        new_entries = []
        Rails.logger.info('new entries')
        # If there were no enties in the first place, just make the call to the dataservice
        if entries.blank?
          new_entries = data_service_function.call(from, to)
        else
          if entries.first.start_date > from
            new_entries += data_service_function.call(from, entries.first.start_date)
          end

          # find_gaps(entries) do |from_gap, to_gap|
          #   new_entries += data_service_function.call(from_gap, to_gap)
          # end

          if entries.last.end_date < to
            new_entries += data_service_function.call(entries.last.end_date, to)
          end
        end
        Rails.logger.info('caching new entries')
        # Cache the newly retrieved data
        cache(connection, table, @user_id, new_entries) if new_entries.present?
      rescue Errors::NotSupportedError => e
        Rails.logger.warn e.message
      end

      def get_data_function(table)
        case table
        when 'heart_rate'
          @data_service.method(:heart_rate)
        when 'sleep'
          @data_service.method(:sleep)
        when 'calories'
          @data_service.method(:calories)
        when 'distance'
          @data_service.method(:distance)
        when 'steps'
          @data_service.method(:steps)
        when 'activities'
          @data_service.method(:activities)
        end
      end

      def find_gaps(entries)
        entries.each_with_index do |entry, i|
          break if i == entries.length - 1
          # TODO: This is dramatically inefficient.
          if entry.end_date != entries[i + 1].start_date
            yield(entry.end_date, entries[i + 1].start_date)
          end
        end
      end

      def cache(connection, table, user_id, new_entries)
        year_of_old_entry = new_entries.first.measurement_moment.strftime('%Y').to_i
        entries = []
        new_entries.each do |entry|
          year_of_current_entry = entry.measurement_moment.strftime('%Y').to_i

          # If the previous year is not equal to the current year we insert a new row
          if year_of_old_entry != year_of_current_entry
            connection.insert(table, user_id, year_of_first_entry, entries)
            year_of_old_entry = year_of_current_entry

            entries = []
          end
          entries << entry
        end

        # Insert the remaining data
        connection.insert(table, user_id, year_of_old_entry, entries)
      end
    end
  end
end
