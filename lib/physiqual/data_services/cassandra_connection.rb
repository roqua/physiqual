require 'singleton'
require 'cassandra'

module Physiqual
  module DataServices
    class CassandraConnection
      include Singleton

      def initialize
        @cluster = nil
        if (!ENV['CASSANDRA_USERNAME']) || (!ENV['CASSANDRA_PASSWORD']) || ENV['CASSANDRA_USERNAME'] == '' then
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

        @query_heart_rate = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM heart_rate
          WHERE user_id = ?
          AND year = ?
          AND time >= ?
          AND time < ?
          ORDER BY time ASC
        ')
        @query_sleep = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM sleep
          WHERE user_id = ?
          AND year = ?
          AND time >= ?
          AND time < ?
          ORDER BY time ASC
        ')
        @query_calories = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM calories
          WHERE user_id = ?
          AND year = ?
          AND time >= ?
          AND time < ?
          ORDER BY time ASC
        ')
        @query_distance = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM distance
          WHERE user_id = ?
          AND year = ?
          AND time >= ?
          AND time < ?
          ORDER BY time ASC
        ')
        @query_steps = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM steps
          WHERE user_id = ?
          AND year = ?
          AND time >= ?
          AND time < ?
          ORDER BY time ASC
        ')
        @query_activities = @session.prepare('
          SELECT time, start_date, end_date, value
          FROM activities
          WHERE user_id = ?
          AND year = ?
          AND time >= ?
          AND time < ?
          ORDER BY time ASC
        ')

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
            times_slice.each_with_index do |time, i|
              case table
                when 'heart_rate'
                  b.add(@insert_heart_rate, arguments: [user_id, year, time.to_time, start_dates_slice[i].to_time, end_dates_slice[i].to_time, BigDecimal(values_slice[i], 10)])
                when 'sleep'
                  b.add(@insert_sleep, arguments: [user_id, year, time.to_time, start_dates_slice[i].to_time, end_dates_slice[i].to_time, BigDecimal(values_slice[i], 10)])
                when 'calories'
                  b.add(@insert_calories, arguments: [user_id, year, time.to_time, start_dates_slice[i].to_time, end_dates_slice[i].to_time, BigDecimal(values_slice[i], 10)])
                when 'distance'
                  b.add(@insert_distance, arguments: [user_id, year, time.to_time, start_dates_slice[i].to_time, end_dates_slice[i].to_time, BigDecimal(values_slice[i], 10)])
                when 'steps'
                  b.add(@insert_steps, arguments: [user_id, year, time.to_time, start_dates_slice[i].to_time, end_dates_slice[i].to_time, BigDecimal(values_slice[i], 10)])
                when 'activities'
                  b.add(@insert_activities, arguments: [user_id, year, time.to_time, start_dates_slice[i].to_time, end_dates_slice[i].to_time, values_slice[i], 10])
              end
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
            user_id text,
            year int,
            time timestamp,
            start_date timestamp,
            end_date timestamp,
            value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS sleep (
            user_id text,
            year int,
            time timestamp,
            start_date timestamp,
            end_date timestamp,
            value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS calories (
            user_id text,
            year int,
            time timestamp,
            start_date timestamp,
            end_date timestamp,
            value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS distance (
            user_id text,
            year int,
            time timestamp,
            start_date timestamp,
            end_date timestamp,
            value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS steps (
            user_id text,
            year int,
            time timestamp,
            start_date timestamp,
            end_date timestamp,
            value decimal,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
        @session.execute('
          CREATE TABLE IF NOT EXISTS activities (
            user_id text,
            year int,
            time timestamp,
            start_date timestamp,
            end_date timestamp,
            value varchar,
            PRIMARY KEY ((user_id, year), time)
          )
        ')
      end
    end
  end
end
