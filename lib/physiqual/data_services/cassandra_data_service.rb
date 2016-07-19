require 'sidekiq-status'

module Physiqual
  module DataServices
    class CassandraDataService < DataServiceDecorator
      def initialize(data_service, user_id)
        super(data_service)
        @user_id = user_id
        @cassandra_connection ||= CassandraConnection.instance
      end

      def service_name
        "cassandra_#{data_service.service_name}"
      end

      def heart_rate(from, to)
        cache_data('heart_rate', @user_id, from, to)
        get_data(@cassandra_connection, @user_id, 'heart_rate', from, to)
      end

      def sleep(from, to)
        cache_data('sleep', @user_id, from, to)
        get_data(@cassandra_connection, @user_id, 'sleep', from, to)
      end

      def calories(from, to)
        cache_data('calories', @user_id, from, to)
        get_data(@cassandra_connection, @user_id, 'calories', from, to)
      end

      def distance(from, to)
        cache_data('distance', @user_id, from, to)
        get_data(@cassandra_connection, @user_id, 'distance', from, to)
      end

      def steps(from, to)
        cache_data('steps', @user_id, from, to)
        get_data(@cassandra_connection, @user_id, 'steps', from, to)
      end

      def activities(from, to)
        cache_data('activities', @user_id, from, to)
        get_data(@cassandra_connection, @user_id, 'activities', from, to)
      end

      def get_data(connection, user_id, variable, from, to)
        entries = []
        years(from, to) do |year, from_per_year, to_per_year|
          case variable
            when 'heart_rate'
              query_result = connection.query_heart_rate(user_id, year, from_per_year, to_per_year)
            when 'sleep'
              query_result = connection.query_sleep(user_id, year, from_per_year, to_per_year)
            when 'calories'
              query_result = connection.query_calories(user_id, year, from_per_year, to_per_year)
            when 'distance'
              query_result = connection.query_distance(user_id, year, from_per_year, to_per_year)
            when 'steps'
              query_result = connection.query_steps(user_id, year, from_per_year, to_per_year)
            when 'activities'
              query_result = connection.query_activities(user_id, year, from_per_year, to_per_year)
          end

          entries += make_data_entries(variable, query_result)
        end
        entries
      end

      private
      
      def cache_data(variable, user_id, from, to)
        job = Physiqual::Workers::CacheWorker.perform_async(data_service, self, variable, user_id, from, to)
        #job = Physiqual::Workers::CacheWorker.new.perform(data_service, self, variable, user_id, from, to)
        while Sidekiq::Status.queued? job or Sidekiq::Status.working? job
          Rails.logger.info('Sleeping!')
          Kernel.sleep(1)
        end
      end

      def years(from, to)
        from_year = from.strftime('%Y').to_i
        to_year = to.strftime('%Y').to_i
        (from_year..to_year).each do |year|
          from_per_year = from_year < year ? Time.zone.local(year, 1, 1, 0, 0, 0) : from
          to_per_year = to_year > year ? Time.zone.local(year, 12, 31, 23, 59, 59) : to
          yield(year, from_per_year, to_per_year)
        end
      end

      def make_data_entries(table, results)
        return [] if results.blank?
        entries = []
        results.each do |result|
          # TODO Should this be to_i or to_f
          value = table == 'activities' ? result['value'] : result['value'].to_i
          entries << DataEntry.new(start_date: result['start_date'].in_time_zone,
                                   end_date: result['end_date'].in_time_zone,
                                   values: [value],
                                   measurement_moment: result['time'].in_time_zone)
        end
        entries
      end
    end
  end
end
