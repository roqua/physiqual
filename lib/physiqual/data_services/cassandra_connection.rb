module Physiqual
  module DataServices
    class CassandraConnection
      include Singleton

      def initialize()
        @cluster = Cassandra.cluster(
            username: config.cassandra_username,
            password: config.cassandra_password,
            hosts: config.cassandra_host_urls
          )
        @session = cluster.connect(config.cassandra_keyspace)
        @insert_heart_rate_statement = session.prepare('')
        @insert_sleep_statement = session.prepare('')
        @insert_calories_statement = session.prepare('')
        @insert_distance_statement = session.prepare('')
        @insert_steps_statement = session.prepare('')
        @insert_activities_statement = session.prepare('')
      end
    end
  end
end
