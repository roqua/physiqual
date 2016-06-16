module Physiqual
  module DataServices
    class CassandraDataService < DataServiceDecorator
      def initialize(data_service, user_id)
        super(data_service)
        @user_id = user_id
        @connection = CassandraConnection.instance
      end

      def service_name
        "cassandra_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        get_data('heart_rate', from, to)
      end

      def sleep(from, to)
        get_data('sleep', from, to)
      end

      def calories(from, to)
        get_data('calories', from, to)
      end

      def distance(from, to)
        get_data('distance', from, to)
      end

      def steps(from, to)
        get_data('steps', from, to)
      end

      def activities(from, to)
        get_data('activities', from, to)
      end

      private

      def get_data(table, from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += case table
                     when 'heart_rate'
                       make_data_entries(@connection.query_heart_rate(@user_id, year, from_per_year, to_per_year))
                     when 'sleep'
                       make_data_entries(@connection.query_sleep(@user_id, year, from_per_year, to_per_year))
                     when 'calories'
                       make_data_entries(@connection.query_calories(@user_id, year, from_per_year, to_per_year))
                     when 'distance'
                       make_data_entries(@connection.query_distance(@user_id, year, from_per_year, to_per_year))
                     when 'steps'
                       make_data_entries(@connection.query_steps(@user_id, year, from_per_year, to_per_year))
                     when 'activities'
                       make_data_entries(@connection.query_activities(@user_id, year, from_per_year, to_per_year))
                     end
        end
        data_service_function = get_data_function(table)
        new_entries = []
        if entries.blank?
          new_entries = data_service_function.call(from, to)
        else
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service_function.call(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service_function.call(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache(table, @user_id, new_entries)
        end
        entries + new_entries
      end

      def get_data_function(table)
        case table
        when 'heart_rate'
          data_service.method(:heart_rate)
        when 'sleep'
          data_service.method(:sleep)
        when 'calories'
          data_service.method(:calories)
        when 'distance'
          data_service.method(:distance)
        when 'steps'
          data_service.method(:steps)
        when 'activities'
          data_service.method(:activities)
        end
      end

      def years(from, to)
        from_year = from.strftime('%Y').to_i
        to_year = to.strftime('%Y').to_i
        (from_year..to_year).each do |year|
          from_per_year = if from_year < year
                            Time.zone.local(year, 1, 1, 0, 0, 0)
                          else
                            from
                          end
          to_per_year = if to_year > year
                          Time.zone.local(year, 12, 31, 23, 59, 59)
                        else
                          to
                        end
          yield(year, from_per_year, to_per_year)
        end
      end

      def find_gaps(entries)
        entries.each_with_index do |entry, i|
          break if i == entries.length - 1
          if entry.end_date != entries[i + 1].start_date
            yield(entry.end_date, entries[i + 1].start_date)
          end
        end
      end

      def make_data_entries(results)
        return [] if results.blank?
        entries = []
        results.each do |result|
          entries << DataEntry.new(start_date: result['start_date'].in_time_zone, end_date: result['end_date'].in_time_zone,
                                   values: result['value'],
                                   measurement_moment: result['time'].in_time_zone)
        end
        entries
      end

      def cache(table, user_id, new_entries)
        year = new_entries.first.measurement_moment.strftime('%Y').to_i
        times = []
        start_dates = []
        end_dates = []
        values = []
        new_entries.each do |entry|
          if year != entry.measurement_moment.strftime('%Y').to_i
            Physiqual::CacheWorker.perform_async(table, user_id, year, times, start_dates, end_dates, values)
            year = entry.measurement_moment.strftime('%Y').to_i
            times = []
            start_dates = []
            end_dates = []
            values = []
          end
          times << entry.measurement_moment
          start_dates << entry.start_date
          end_dates << entry.end_date
          values << entry.values.first
          if entry == new_entries.last
            Physiqual::CacheWorker.perform_async(table, user_id, year, times, start_dates, end_dates, values)
          end
        end
      end
    end
  end
end
