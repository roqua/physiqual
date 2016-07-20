require 'singleton'
require 'cassandra'

module Physiqual
  class CassandraConnection
    include Singleton
    SLICE_SIZE = 100

    def initialize
      # Setup the connection to the cluster
      Rails.logger.info(Physiqual.cassandra_username)
      Rails.logger.info(Physiqual.cassandra_password)
      Rails.logger.info(Physiqual.cassandra_host_urls)
      cluster = initialize_cassandra_cluster
      @session = cluster.connect(Physiqual.cassandra_keyspace)

      variables = { 'heart_rate' => 'decimal',
                    'sleep' => 'decimal',
                    'calories' => 'decimal',
                    'distance' => 'decimal',
                    'steps' => 'decimal',
                    'activities' => 'varchar' }

      initialize_database(variables)
    end

    def insert(variable, user_id, year, entries)
      # Slice the dates in chuncs of SLICE_SIZE
      entries = entries.each_slice(SLICE_SIZE).to_a

      entries.each_with_index do |entry_slice|
        current_batch = create_batches(entry_slice, variable, user_id, year)
        @session.execute(current_batch)
      end
    end

    def create_batches(entry_slice, variable, user_id, year)
      @session.batch do |batch|
        entry_slice.each do |entry|
          value = entry.values.first
          # If the table is 'activities', we should not convert the slice to a bigdecimal
          value = BigDecimal(value, Float::DIG + 1) if variable != 'activities'

          # Retrieve the prepared statement
          insert_type = @insert_queries[variable]
          batch.add(insert_type,
                    arguments: [user_id, year,
                                entry.measurement_moment.to_time,
                                entry.start_date.to_time,
                                entry.end_date.to_time, value])
        end
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

    def initialize_cassandra_cluster
      if Physiqual.cassandra_username.blank? || Physiqual.cassandra_password.blank?
        return Cassandra.cluster(hosts: Physiqual.cassandra_urls)
      end

      Cassandra.cluster(
        username: Physiqual.cassandra_username,
        password: Physiqual.cassandra_password,
        hosts: Physiqual.cassandra_urls
      )
    end

    def initialize_database(variable_names)
      @insert_queries = {}
      @queries = {}
      variable_names.each do |variable, type|
        create_table(variable, type)
        @insert_queries[variable] = prepare_insert(variable)
        @queries[variable] = prepare_query(variable)
      end
    end

    def create_keyspace(_keypsace_name)
      query = "CREATE KEYSPACE #{keyspace_name}
      WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};"
      @session.execute(query)
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
