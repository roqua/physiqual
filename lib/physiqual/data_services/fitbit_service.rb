module Physiqual
  module DataServices
    class FitbitService < DataService
      def initialize(session)
        @session = session
        @intraday = true
      end

      def service_name
        FitbitToken.csrf_token
      end

      def profile
        @session.get('/profile.json')
      end

      def distance(from, to)
        resource = 'activities'
        activity = 'distance'
        activity_call(from, to, resource, activity)
      end

      def heart_rate(from, to)
        resource = 'activities'
        activity = 'heart'
        activity_call(from, to, resource, activity)
      end

      def sleep(from, to)
        resource = 'sleep'
        subresource = 'minutesAsleep'
        from = from.strftime(DATE_FORMAT)
        to = to.strftime(DATE_FORMAT)
        daily_summary(from, to, resource, subresource)
      end

      def steps(from, to)
        resource = 'activities'
        activity = 'steps'
        activity_call(from, to, resource, activity)
      end

      def calories(from, to)
        resource = 'activities'
        activity = 'calories'
        activity_call(from, to, resource, activity)
      end

      def activities(_from, _to)
        fail Errors::NotSupportedError, 'Activities Not supported by fitbit!'
      end

      private

      def activity_call(from, to, resource, subresource)
        from = from.strftime(DATE_FORMAT)
        to = to.strftime(DATE_FORMAT)
        result = if @intraday
                   intraday_summary(from, to, resource, subresource)
                 else
                   daily_summary(from, to, resource, subresource)
        end
        result
      end

      def daily_summary(from, to, resource, subresource)
        data = @session.get("/#{resource}/#{subresource}/date/#{from}/#{to}.json")
        process_entries(data["#{resource}-#{subresource}"])
      end

      def intraday_summary(from, to, resource, subresource)
        results = []
        (from.to_date..to.to_date).each do |date|
          data = @session.get("/#{resource}/#{subresource}/date/#{date}/1d/1min.json")
          results << process_intraday_entries(data["#{resource}-#{subresource}-intraday"], date)
        end
        results.flatten
      end

      def process_intraday_entries(entries, date)
        entries = entries['dataset']
        result = []

        return {} if entries.nil?
        entries.each do |entry|
          value = entry['value']
          current_value = [convert_to_int_if_needed(value)]
          endd = Time.parse("#{date} #{entry['time']}").in_time_zone
          start = endd - 1.minute
          measurement_moment = endd
          result << DataEntry.new(start_date: start, end_date: endd, values: current_value,
                                  measurement_moment: measurement_moment)
        end
        result
      end

      def process_entries(entries)
        result = []
        entries.each do |entry|
          value = entry['value']
          current_value = [convert_to_int_if_needed(value)]
          endd = entry['dateTime'].to_time.in_time_zone
          start = endd - 24.hours
          measurement_moment = endd
          result << DataEntry.new(start_date: start, end_date: endd, values: current_value,
                                  measurement_moment: measurement_moment)
        end
        result
      end

      def convert_to_int_if_needed(value)
        !value.is_a?(Hash) && value.to_s == value.to_i.to_s ? value.to_i : value
      end
    end
  end
end
