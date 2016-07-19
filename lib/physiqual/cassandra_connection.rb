require 'singleton'
require 'cassandra'

module Physiqual
  class CassandraConnection
    include Singleton
    SLICE_SIZE = 100

    def initialize
      # Setup the connection to the cluster
      if Physiqual.cassandra_username.blank? || Physiqual.cassandra_password.blank?
        cluster = Cassandra.cluster(
          hosts: Physiqual.cassandra_host_urls
        )
      else
        cluster = Cassandra.cluster(
          username: ENV['CASSANDRA_USERNAME'],
          password: ENV['CASSANDRA_PASSWORD'],
          hosts: Physiqual.cassandra_host_urls
        )
      end
      @session = cluster.connect('physiqual')

      variables = { 'heart_rate' => 'decimal',
                    'sleep' => 'decimal',
                    'calories' => 'decimal',
                    'distance' => 'decimal',
                    'steps' => 'decimal',
                    'activities' => 'varchar' }

      initialize_database(variables)
    end

    def insert(table, user_id, year, entries)
      # Slice the dates in chuncs of SLICE_SIZE
      entries = entries.each_slice(SLICE_SIZE).to_a

      entries.each_with_index do |entry_slice|
        batch = @session.batch do |b|
          entry_slice.each do |entry|
            time = entry.measurement_moment
            start_date = entry.start_date
            end_date = entry.end_date
            value = entry.values.first
            # If the table is 'activities', we should not convert the slice to a bigdecimal
            value = BigDecimal(value, Float::DIG + 1) if table != 'activities'

            # Retrieve the prepared statement
            insert_type = @insert_queries[table]
            b.add(insert_type, arguments: [user_id, year, time.to_time, start_date.to_time,
                                           end_date.to_time, value])
          end
        end
        @session.execute(batch)
      end
    end

    def query_heart_rate(user_id, year, from, to)
      @session.execute(@queries['heart_rate'], arguments: [user_id, year, from, to])
    end

    def query_sleep(user_id, year, from, to)
      @session.execute(@queries['sleep'], arguments: [user_id, year, from, to])
    end

    def query_calories(user_id, year, from, to)
      @session.execute(@queries['calories'], arguments: [user_id, year, from, to])
    end

    def query_distance(user_id, year, from, to)
      @session.execute(@queries['distance'], arguments: [user_id, year, from, to])
    end

    def query_steps(user_id, year, from, to)
      @session.execute(@queries['steps'], arguments: [user_id, year, from, to])
    end

    def query_activities(user_id, year, from, to)
      @session.execute(@queries['activities'], arguments: [user_id, year, from, to])
    end

    private

    def slice(times, start_dates, end_dates, values)
      [times.each_slice(SLICE_SIZE).to_a,
       start_dates.each_slice(SLICE_SIZE).to_a,
       end_dates.each_slice(SLICE_SIZE).to_a,
       values.each_slice(SLICE_SIZE).to_a]
    end

    def initialize_database(variable_names)
      @insert_queries = {}
      @queries = {}
      variable_names.each do |variable, type|
        @insert_queries[variable] = prepare_insert(variable)
        @queries[variable] = prepare_query(variable)
        create_table(variable, type)
      end
    end

    def prepare_insert(table_name)
      query = "INSERT INTO #{table_name} (user_id, year, time, start_date, end_date, value) VALUES (?, ?, ?, ?, ?, ?)"
      @session.prepare(query)
    end

    def prepare_query(table_name)
      query = "
          SELECT time, start_date, end_date, value
          FROM #{table_name}
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        "
      @session.prepare(query)
    end

    def create_table(name, value_type)
      query = "
            CREATE TABLE IF NOT EXISTS #{name} (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value #{value_type},
            PRIMARY KEY ((user_id, year), time)
          )
        "
      @session.execute(query)
    end
  end
end
