require 'sidekiq'

module Physiqual
  class CacheWorker
    include Sidekiq::Worker
    def perform(table, user_id, year, times, start_dates, end_dates, values)
      connection = DataServices::CassandraConnection.instance
      case table
        when 'heart_rate'
          connection.insert_heart_rate(user_id, year, times, start_dates, end_dates, values)
        when 'sleep'
          connection.insert_sleep(user_id, year, times, start_dates, end_dates, values)
        when 'calories'
          connection.insert_calories(user_id, year, times, start_dates, end_dates, values)
        when 'distance'
          connection.insert_distance(user_id, year, times, start_dates, end_dates, values)
        when 'steps'
          connection.insert_steps(user_id, year, times, start_dates, end_dates, values)
        when 'activities'
          connection.insert_activities(user_id, year, times, start_dates, end_dates, values)
      end
    end
  end
end