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
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += make_data_entries(@connection.query_heart_rate(@user_id, year, from_per_year, to_per_year))
        end
        new_entries = []
        if entries.blank?
          new_entries = data_service.heart_rate(from, to)
        else
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service.heart_rate(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service.heart_rate(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache('heart_rate', @user_id, new_entries)
        end
        entries + new_entries
      end

      def sleep(from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += make_data_entries(@connection.query_sleep(@user_id, year, from_per_year, to_per_year))
        end
        new_entries = []
        if entries.blank?
          new_entries = data_service.sleep(from, to)
        else
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service.sleep(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service.sleep(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache('sleep', @user_id, new_entries)
        end
        entries + new_entries
      end

      def calories(from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += make_data_entries(@connection.query_calories(@user_id, year, from_per_year, to_per_year))
        end
        new_entries = []
        if entries.blank?
          new_entries = data_service.calories(from, to)
        else
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service.calories(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service.calories(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache('calories', @user_id, new_entries)
        end
        entries + new_entries
      end

      def distance(from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += make_data_entries(@connection.query_distance(@user_id, year, from_per_year, to_per_year))
        end
        new_entries = []
        if entries.blank?
          new_entries = data_service.distance(from, to)
        else
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service.distance(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service.distance(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache('distance', @user_id, new_entries)
        end
        entries + new_entries
      end

      def steps(from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += make_data_entries(@connection.query_steps(@user_id, year, from_per_year, to_per_year))
        end
        new_entries = []
        if entries.blank?
          new_entries = data_service.steps(from, to)
        else
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service.steps(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service.steps(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache('steps', @user_id, new_entries)
        end
        entries + new_entries
      end

      def activities(from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += make_data_entries(@connection.query_activities(@user_id, year, from_per_year, to_per_year))
        end
        new_entries = []
        if entries.blank?
          new_entries = data_service.activities(from, to)
        else
          if entries.first.start_date > from
            new_entries += data_service.activities(from, entries.last.start_date)
          end
          find_gaps(entries) do |from_gap, to_gap|
            new_entries += data_service.activities(from_gap, to_gap)
          end
          if entries.last.end_date < to
            new_entries += data_service.activities(entries.last.end_date, to)
          end
        end
        if new_entries.present?
          cache('activities', @user_id, new_entries)
        end
        entries + new_entries
      end

      private

      def years(from, to)
        from_year = from.strftime('%Y').to_i
        to_year = to.strftime('%Y').to_i
        (from_year..to_year).each do |year|
          if from_year < year
            from_per_year = Time.zone.local(year, 1, 1, 0, 0, 0)
          else
            from_per_year = from
          end
          if to_year > year
            to_per_year = Time.zone.local(year, 12, 31, 23, 59, 59)
          else
            to_per_year = to
          end
          yield(year, from_per_year, to_per_year)
        end
      end

      def find_gaps(entries)
        entries.each_with_index do |entry, i|
          break if i == entries.length - 1
          if entry.end_date != entries[i+1].start_date
            yield(entry.end_date, entries[i+1].start_date)
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
