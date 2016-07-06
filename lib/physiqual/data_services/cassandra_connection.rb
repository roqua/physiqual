require 'singleton'
require 'cassandra'

module Physiqual
  module DataServices
    class CassandraConnection
      include Singleton
      SLICE_SIZE = 100

      def initialize
        @cluster = nil
        if !ENV['CASSANDRA_USERNAME'] || !ENV['CASSANDRA_PASSWORD'] || ENV['CASSANDRA_USERNAME'] == ''
          @cluster = Cassandra.cluster(
            hosts: (ENV['CASSANDRA_HOST_URLS'] || 'physiqual.dev').split(' ')
          )
        else
          @cluster = Cassandra.cluster(
            username: ENV['CASSANDRA_USERNAME'],
            password: ENV['CASSANDRA_PASSWORD'],
            hosts: (ENV['CASSANDRA_HOST_URLS'] || 'physiqual.dev').split(' ')
          )
        end
        @session = @cluster.connect('physiqual')

        init_db
        init_insert
        init_query
      end

      def insert(table, user_id, year, times, start_dates, end_dates, values)
        times_slices, start_dates_slices, end_dates_slices, values_slices =
          slice(times, start_dates, end_dates, values)
        times_slices.each_with_index do |times_slice, i|
          start_dates_slice = start_dates_slices[i]
          end_dates_slice = end_dates_slices[i]
          values_slice = values_slices[i]
          batch = @session.batch do |b|
            times_slice.each_with_index do |time, j|
              insert_type = nil
              value = BigDecimal(values_slice[j], Float::DIG + 1)
              case table
              when 'heart_rate'
                insert_type = @insert_heart_rate
              when 'sleep'
                insert_type = @insert_sleep
              when 'calories'
                insert_type = @insert_calories
              when 'distance'
                insert_type = @insert_distance
              when 'steps'
                insert_type = @insert_steps
              when 'activities'
                insert_type = @insert_activities
                value = values_slice[j]
              end
              b.add(insert_type, arguments: [user_id, year, time.to_time, start_dates_slice[j].to_time,
                                             end_dates_slice[j].to_time, value])
            end
          end
          @session.execute(batch)
        end
      end

      def slice(times, start_dates, end_dates, values)
        return times.each_slice(SLICE_SIZE).to_a,
            start_dates.each_slice(SLICE_SIZE).to_a,
            end_dates.each_slice(SLICE_SIZE).to_a,
            values.each_slice(SLICE_SIZE).to_a
      end

      def query_heart_rate(user_id, year, from, to)
        @session.execute(@query_heart_rate, arguments: [user_id, year, from, to])
      end

      def query_sleep(user_id, year, from, to)
        @session.execute(@query_sleep, arguments: [user_id, year, from, to])
      end

      def query_calories(user_id, year, from, to)
        @session.execute(@query_calories, arguments: [user_id, year, from, to])
      end

      def query_distance(user_id, year, from, to)
        @session.execute(@query_distance, arguments: [user_id, year, from, to])
      end

      def query_steps(user_id, year, from, to)
        @session.execute(@query_steps, arguments: [user_id, year, from, to])
      end

      def query_activities(user_id, year, from, to)
        @session.execute(@query_activities, arguments: [user_id, year, from, to])
      end

      private

      def init_db
        create_table('heart_rate', 'decimal')
        create_table('sleep', 'decimal')
        create_table('calories', 'decimal')
        create_table('distance', 'decimal')
        create_table('steps', 'decimal')
        create_table('activities', 'varchar')
      end

      def create_table(name, value_type)
        @session.execute("
            CREATE TABLE IF NOT EXISTS #{name} (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value #{value_type},
            PRIMARY KEY ((user_id, year), time)
          )
        ")
      end

      def init_insert
        @insert_heart_rate = prepare_insert('heart_rate')
        @insert_sleep = prepare_insert('sleep')
        @insert_calories = prepare_insert('calories')
        @insert_distance = prepare_insert('distance')
        @insert_steps = prepare_insert('steps')
        @insert_activities = prepare_insert('activities')
      end

      def prepare_insert(table_name)
        @session.prepare("
           INSERT INTO #{table_name} (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ")
      end

      def init_query
        @query_heart_rate = prepare_query('heart_rate')
        @query_sleep = prepare_query('sleep')
        @query_calories = prepare_query('calories')
        @query_distance = prepare_query('distance')
        @query_steps = prepare_query('steps')
        @query_activities = prepare_query('activities')
      end

      def prepare_query(table_name)
        @session.prepare("
          SELECT time, start_date, end_date, value
          FROM #{table_name}
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ")
      end
    end
  end
end
