require 'singleton'
require 'cassandra'

module Physiqual
  module DataServices
    class CassandraConnection
      include Singleton

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
        times_slices = times.each_slice(100).to_a
        start_dates_slices = start_dates.each_slice(100).to_a
        end_dates_slices = end_dates.each_slice(100).to_a
        values_slices = values.each_slice(100).to_a

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
        @session.execute('
          CREATE TABLE IF NOT EXISTS heart_rate (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS sleep (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS calories (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS distance (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS steps (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS activities (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value varchar,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
      end

      def init_insert
        @insert_heart_rate = @session.prepare('
          INSERT INTO heart_rate (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ')
        @insert_sleep = @session.prepare('
          INSERT INTO sleep (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ')
        @insert_calories = @session.prepare('
          INSERT INTO calories (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ')
        @insert_distance = @session.prepare('
          INSERT INTO distance (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ')
        @insert_steps = @session.prepare('
          INSERT INTO steps (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ')
        @insert_activities = @session.prepare('
          INSERT INTO activities (
            user_id, year, time, start_date, end_date, value
          ) VALUES (
            ?, ?, ?, ?, ?, ?
          )
        ')
      end

      def init_query
        @query_heart_rate = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM heart_rate
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ')
        @query_sleep = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM sleep
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ')
        @query_calories = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM calories
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ')
        @query_distance = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM distance
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ')
        @query_steps = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM steps
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ')
        @query_activities = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM activities
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        ')
      end
    end
  end
end
