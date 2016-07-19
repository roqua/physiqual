require 'sidekiq-status'

module Physiqual
  module DataServices
    class CassandraDataService < DataServiceDecorator
      def initialize(data_service, user_id)
        super(data_service)
        @user_id = user_id
      end

      def service_name
        "cassandra_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        cache_data('heart_rate', @user_id, from, to)
        CassandraDataService.get_data(cassandra_connection, @user_id, 'heart_rate', from, to)
      end

      def sleep(from, to)
        cache_data('sleep', @user_id, from, to)
        CassandraDataService.get_data(cassandra_connection, @user_id, 'sleep', from, to)
      end

      def calories(from, to)
        cache_data('calories', @user_id, from, to)
        CassandraDataService.get_data(cassandra_connection, @user_id, 'calories', from, to)
      end

      def distance(from, to)
        cache_data('distance', @user_id, from, to)
        CassandraDataService.get_data(cassandra_connection, @user_id, 'distance', from, to)
      end

      def steps(from, to)
        cache_data('steps', @user_id, from, to)
        CassandraDataService.get_data(cassandra_connection, @user_id, 'steps', from, to)
      end

      def activities(from, to)
        cache_data('activities', @user_id, from, to)
        CassandraDataService.get_data(cassandra_connection, @user_id, 'activities', from, to)
      end

      def self.get_data(connection, user_id, table, from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          entries += case table
                     when 'heart_rate'
                       make_data_entries(table,
                                         connection.query_heart_rate(user_id, year, from_per_year, to_per_year))
                     when 'sleep'
                       make_data_entries(table,
                                         connection.query_sleep(user_id, year, from_per_year, to_per_year))
                     when 'calories'
                       make_data_entries(table,
                                         connection.query_calories(user_id, year, from_per_year, to_per_year))
                     when 'distance'
                       make_data_entries(table,
                                         connection.query_distance(user_id, year, from_per_year, to_per_year))
                     when 'steps'
                       make_data_entries(table,
                                         connection.query_steps(user_id, year, from_per_year, to_per_year))
                     when 'activities'
                       make_data_entries(table,
                                         connection.query_activities(user_id, year, from_per_year, to_per_year))
                     end
        end
        entries
      end

      private

      def cassandra_connection
        @connection ||= CassandraConnection.instance
        @connection
      end

      def cache_data(table, user_id, from, to)
        job = Physiqual::CacheWorker.perform_async(table, user_id, from, to)
        while Sidekiq::Status.queued? job or Sidekiq::Status.working? job
          Kernel.sleep(1)
        end
      end

      class << self
        private

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

        def make_data_entries(table, results)
          return [] if results.blank?
          entries = []
          results.each do |result|
            value = if table == 'activities'
                      result['value']
                    else
                      result['value'].to_f
                    end
            entries << DataEntry.new(start_date: result['start_date'].in_time_zone,
                                     end_date: result['end_date'].in_time_zone,
                                     values: value,
                                     measurement_moment: result['time'].in_time_zone)
          end
          entries
        end
      end
    end
  end
end
