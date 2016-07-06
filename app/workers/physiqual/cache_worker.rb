require 'sidekiq'

module Physiqual
  class CacheWorker
    include Sidekiq::Worker
    def perform(table, user_id, from, to)
      token = User.find_by_user_id(user_id).physiqual_token
      return [] unless token.complete?
      session = Sessions::TokenAuthorizedSession.new(token)
      @data_service = DataServices::DataServiceFactory.fabricate!(token.class.csrf_token, session)
      @user_id = user_id
      connection = DataServices::CassandraConnection.instance
      from = Time.zone.parse(from)
      to = Time.zone.parse(to)
      store_data(connection, table, from, to)
    end

    private

    def store_data(connection, table, from, to)
      entries = DataServices::CassandraDataService.get_data(connection, @user_id, table, from, to)
      data_service_function = get_data_function(table)
      new_entries = []
      if entries.blank?
        new_entries = data_service_function.call(from, to)
      else
        if entries.first.start_date > from
          new_entries += data_service_function.call(from, entries.first.start_date)
        end
        find_gaps(entries) do |from_gap, to_gap|
          new_entries += data_service_function.call(from_gap, to_gap)
        end
        if entries.last.end_date < to
          new_entries += data_service_function.call(entries.last.end_date, to)
        end
      end
      cache(connection, table, @user_id, new_entries) if new_entries.present?
    rescue Errors::NotSupportedError => e
      Rails.logger.warn e.message
    end

    def get_data_function(table)
      case table
      when 'heart_rate'
        @data_service.method(:heart_rate)
      when 'sleep'
        @data_service.method(:sleep)
      when 'calories'
        @data_service.method(:calories)
      when 'distance'
        @data_service.method(:distance)
      when 'steps'
        @data_service.method(:steps)
      when 'activities'
        @data_service.method(:activities)
      end
    end

    def find_gaps(entries)
      entries.each_with_index do |entry, i|
        break if i == entries.length - 1
        if entry.end_date != entries[i + 1].start_date
          yield(entry.end_date, entries[i + 1].start_date)
        end
      end
    end

    def cache(connection, table, user_id, new_entries)
      year = new_entries.first.measurement_moment.strftime('%Y').to_i
      times = []
      start_dates = []
      end_dates = []
      values = []
      new_entries.each do |entry|
        if year != entry.measurement_moment.strftime('%Y').to_i
          connection.insert(table, user_id, year, times, start_dates, end_dates, values)
          year = entry.measurement_moment.strftime('%Y').to_i
          times = []
          start_dates = []
          end_dates = []
          values = []
        end
        times << entry.measurement_moment
        start_dates << entry.start_date
        end_dates << entry.end_date
        values << entry.values.first
        if entry == new_entries.last
          connection.insert(table, user_id, year, times, start_dates, end_dates, values)
        end
      end
    end
  end
end
