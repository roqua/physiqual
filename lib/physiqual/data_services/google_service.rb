module Physiqual
  module DataServices
    class GoogleService < DataService
      ACTIVITIES = YAML.load_file("#{Physiqual::Engine.root}/db/seeds/google_activities.yml")

      HEART_RATE_URL = 'derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm'
      STEPS_URL      = 'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps'
      ACTIVITY_URL   = 'derived:com.google.activity.segment:com.google.android.gms:merge_activity_segments'
      SLEEP_URL      = 'derived:com.google.activity.segment:com.google.android.gms:merge_activity_segments'
      CALORIES_URL   = 'derived:com.google.calories.expended:com.google.android.gms:merge_calories_expended'
      DISTANCE_URL   = 'derived:com.google.distance.delta:com.google.android.gms:pruned_distance'

      def initialize(session)
        @session = session
      end

      def service_name
        GoogleToken.csrf_token
      end

      def sources
        @datasources = @session.get('/dataSources')
        unless @datasources.blank?
          @datasources = @datasources['dataSource'].map { |x| [x['dataType']['name'], x['dataStreamId']] }
        end
        @datasources
      end

      def heart_rate(from, to)
        activity_data(from, to, HEART_RATE_URL, 'fpVal')
      end

      def steps(from, to)
        activity_data(from, to, STEPS_URL, 'intVal')
      end

      def activities(from, to)
        activity_data(from, to, ACTIVITY_URL, 'intVal') { |value| ACTIVITIES[value] }
      end

      def calories(from, to)
        activity_data(from, to, CALORIES_URL, 'fpVal')
      end

      def distance(from, to)
        activity_data(from, to, DISTANCE_URL, 'fpVal')
      end

      def sleep(from, to)
        specific_activity_data(from, to, SLEEP_URL, 72) # 72 = sleeping
      end

      private

      def activity_data(from, to, url, value_type, &block)
        res = point_results(from, to, url)

        loop_through_results(res) do |value, start, endd, results_array|
          current_value = value[value_type].to_i
          current_value = [(block_given? ? block.call(current_value) : current_value)]
          results_array << DataEntry.new(start: start, end: endd, values: current_value)
        end
      end

      def specific_activity_data(from, to, url, activity_type)
        res = point_results(from, to, url)

        loop_through_results(res) do |value, start, endd, results_array|

          # If the current activity is not the specified activity, skip it
          next unless value['intVal'] == activity_type
          results_array << DataEntry.new(start: start, end: endd, values: [(endd - start) / 60])
        end
      end

      def point_results(from, to, url)
        from_nanos = convert_time_to_nanos(from)
        to_nanos = convert_time_to_nanos(to)
        res = access_datasource(url, from_nanos, to_nanos)
        res = res['point']
        res
      end

      def loop_through_results(res)
        return [] if res.blank?
        results = []

        res.each do |entry|
          start = (entry['startTimeNanos'].to_i / 10e8).to_i
          endd = (entry['endTimeNanos'].to_i / 10e8).to_i

          # If the current timestep is higher than the final timestep, don't include it
          actual_timestep = Time.at((start + endd) / 2)
          next if actual_timestep > to

          yield(entry['value'].first, start, endd, results)
        end
        results
      end

      def access_datasource(id, from, to)
        @session.get("/dataSources/#{id}/datasets/#{from}-#{to}")
      end

      def convert_time_to_nanos(time)
        length = 19
        time = "#{time.to_i}"
        time = "#{time}#{('0' * (length - time.length))}"
        time
      end
    end
  end
end
