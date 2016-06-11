module Physiqual
  module DataServices
    class CassandraConnection
      include Singleton

      def initialize
        @cluster = Cassandra.cluster(
            username: config.cassandra_username,
            password: config.cassandra_password,
            hosts: config.cassandra_host_urls
          )
        @session = cluster.connect(config.cassandra_keyspace)
        @insert_statement = @session.prepare('
          INSERT INTO ? (
            userid, year, time, ?
          ) VALUES (
            ?, ?, ?, ?
          )
        ')
        @query_statement = @session.prepare('
          SELECT time, ?
          FROM ?
          WHERE userid = ?
          AND year = ?
          AND time IN (?, ?)
          ORDER BY time ASC
        ')
      end

      def insert(table, userid, year, time, value)
        @session.execute(@insert_statement, arguments: [table, table, userid, year, time, value])
      end

      def query(table, userid, year, from, to)
        @session.execute(@query_statement, arguments: [table, table, userid, year, from, to])
      end

      def init_db
        create_statement = @session.prepare("
          CREATE TABLE IF NOT EXISTS #{config.cassandra_keyspace}.? (
            userid text,
            year int,
            time timestamp,
            ? ?
            PRIMARY KEY ((userid, year), time)
        ")
        @session.execute(create_statement, arguments: ['heart_rate', 'heart_rate', 'decimal'])
        @session.execute(create_statement, arguments: ['sleep', 'sleep', 'decimal'])
        @session.execute(create_statement, arguments: ['calories', 'calories', 'decimal'])
        @session.execute(create_statement, arguments: ['distance', 'distance', 'decimal'])
        @session.execute(create_statement, arguments: ['steps', 'steps', 'decimal'])
        @session.execute(create_statement, arguments: ['activities', 'activities', 'decimal'])
      end
    end
  end
end
