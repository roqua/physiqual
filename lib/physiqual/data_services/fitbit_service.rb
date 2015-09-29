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
  
      def heart_rate(from, to)
        resource = 'activities'
        activity = 'heart'
        activity_call(from, to, resource, activity).map do |hash|
          { date_time_field => hash[date_time_field], values_field => [hash[values_field].first['restingHeartRate']] }
        end
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
        if @intraday
          result = intraday_summary(from, to, resource, subresource)
        else
          result = daily_summary(from, to, resource, subresource)
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
        entries.each do |entry|
          value = entry['value']
          value = convert_to_int_if_needed(value)
          date = Time.parse("#{date} #{entry['time']}")
          result << { date_time_field => date, values_field => [value] }
        end
        result
      end
  
      def process_entries(entries)
        result = []
        entries.each do |entry|
          value = entry['value']
          value = convert_to_int_if_needed(value)
          result << { date_time_field => entry['dateTime'].to_time, values_field => [value] }
        end
        result
      end
  
      def convert_to_int_if_needed(value)
        !value.is_a?(Hash) && value.to_s == value.to_i.to_s ? value.to_i : value
      end
    end
  end
end
