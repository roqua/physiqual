require 'csv'
module Physiqual
  module DataServices
    class ActicalService < DataService

      def initialize(session)
        @session = session
        filename = "#{Physiqual::Engine.root}/ID999.csv"
        @data = []
        CSV.foreach(filename, :headers => true) do |row|
          @data << row.to_hash
        end
        puts @data
      end

      def sources

        steps(Time.new(2014,3,1,10,30), Time.new(2014,4,2,10,30))
      end

      def service_name
        ActicalToken.csrf_token
      end

      def heart_rate(from, to)
        fail Errors::NotSupportedError, 'Heart rate Not supported by Actical!'
      end

      def steps(from, to)
        results = []
        @data.each do |entry|
          date = Time.strptime("#{entry['Date']}T#{entry['Time']}", '%d-%b-%YT%H:%M')
          next if date < from || date > to
          value = entry['Activity Counts']
          results << { date_time_field => date, values_field => [value.to_i] }
        end
        results
      end

      def activities(from, to)
        fail Errors::NotSupportedError, 'Activities Not supported by Actical!'
      end

      def calories(from, to)
        fail Errors::NotSupportedError, 'Calories Not supported by Actical!'
      end

      def distance(from, to)
        fail Errors::NotSupportedError, 'Distance Not supported by Actical!'
      end

      def sleep(from, to)
        fail Errors::NotSupportedError, 'Sleep Not supported by Actical!'
      end
    end
  end
end
