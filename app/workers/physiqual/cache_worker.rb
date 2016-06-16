require 'sidekiq'

module Physiqual
  class CacheWorker
    include Sidekiq::Worker
    def perform(table, user_id, year, times, start_dates, end_dates, values)
      connection = DataServices::CassandraConnection.instance
      connection.insert(table, user_id, year, times, start_dates, end_dates, values)
    end
  end
end