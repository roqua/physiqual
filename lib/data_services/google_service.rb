module DataServices
  # rubocop:disable Metrics/ClassLength, Metrics/MethodLength
  class GoogleService < DataService
    def initialize(session)
      @session = session
    end

    def service_name
      GoogleToken.csrf_token
    end

    def sources
      @datasources = @session.get('/dataSources')
      @datasources = @datasources['dataSource'].map { |x| [x['dataType']['name'], x['dataStreamId']] }
      @datasources
    end

    def heart_rate(from, to)
      heart_rate_url = 'derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm'
      activity_data(from, to, heart_rate_url, 'fpVal')
    end

    def steps(from, to)
      steps_url = 'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps'
      activity_data(from, to, steps_url, 'intVal')
    end

    def activities(from, to)
      activity_url = 'derived:com.google.activity.segment:com.google.android.gms:merge_activity_segments'
      activity_data(from, to, activity_url, 'intVal') { |value| convert_number_to_activity(value) }
    end

    def sleep(from, to)
      #sleep_url = 'derived:com.google.activity.segment:com.urbandroid.sleep:session_activity_segment'
      #access_datasource sleep_url, convert_time_to_nanos(from), convert_time_to_nanos(to)
      fail Errors::NotSupportedError, 'Sleep not supported by google fit!'
    end

    def calories(from, to)
      calories_url = 'derived:com.google.activity.segment:com.google.android.gms:merge_activity_segments'
      activity_data(from, to, calories_url, 'intVal')
    end

    private

    def activity_data(from, to, url, value_type)
      from_nanos = convert_time_to_nanos(from)
      to_nanos = convert_time_to_nanos(to)
      res = access_datasource(url, from_nanos, to_nanos)
      res = res['point']
      results_hash = Hash.new(0)

      res.each do |entry|
        start = (entry['startTimeNanos'].to_i / 10e8).to_i
        endd = (entry['endTimeNanos'].to_i / 10e8).to_i
        actual_timestep = Time.at((start + endd) / 2)

        # If the current timestep is higher than the final timestep, don't include it
        next if actual_timestep > to
        value = entry['value'].first[value_type].to_i
        results_hash[actual_timestep] += value
      end
      results = []

      results_hash.each do |date, value|
        results << { date_time_field => date, values_field => [(block_given? ? yield(value) : value)] }
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

    def convert_number_to_activity(number)
      activities =
        { 9 => 'Aerobics',
          10 => 'Badminton',
          11 => 'Baseball',
          12 => 'Basketball',
          13 => 'Biathlon',
          1 => 'Biking',
          14 => 'Handbiking',
          15 => 'Mountain biking',
          16 => 'Road biking',
          17 => 'Spinning',
          18 => 'Stationary biking',
          19 => 'Utility biking',
          20 => 'Boxing',
          21 => 'Calisthenics',
          22 => 'Circuit training',
          23 => 'Cricket',
          106 => 'Curling',
          24 => 'Dancing',
          102 => 'Diving',
          25 => 'Elliptical',
          103 => 'Ergometer',
          26 => 'Fencing',
          27 => 'Football (American)',
          28 => 'Football (Australian)',
          29 => 'Football (Soccer)',
          30 => 'Frisbee',
          31 => 'Gardening',
          32 => 'Golf',
          33 => 'Gymnastics',
          34 => 'Handball',
          35 => 'Hiking',
          36 => 'Hockey',
          37 => 'Horseback riding',
          38 => 'Housework',
          104 => 'Ice skating',
          0 => 'In vehicle',
          39 => 'Jumping rope',
          40 => 'Kayaking',
          41 => 'Kettlebell training',
          42 => 'Kickboxing',
          43 => 'Kitesurfing',
          44 => 'Martial arts',
          45 => 'Meditation',
          46 => 'Mixed martial arts',
          2 => 'On foot',
          108 => 'Other (unclassified fitness activity)',
          47 => 'P90X exercises',
          48 => 'Paragliding',
          49 => 'Pilates',
          50 => 'Polo',
          51 => 'Racquetball',
          52 => 'Rock climbing',
          53 => 'Rowing',
          54 => 'Rowing machine',
          55 => 'Rugby',
          8 => 'Running',
          56 => 'Jogging',
          57 => 'Running on sand',
          58 => 'Running (treadmill)',
          59 => 'Sailing',
          60 => 'Scuba diving',
          61 => 'Skateboarding',
          62 => 'Skating',
          63 => 'Cross skating',
          105 => 'Indoor skating',
          64 => 'Inline skating (rollerblading)',
          65 => 'Skiing',
          66 => 'Back-country skiing',
          67 => 'Cross-country skiing',
          68 => 'Downhill skiing',
          69 => 'Kite skiing',
          70 => 'Roller skiing',
          71 => 'Sledding',
          72 => 'Sleeping',
          109 => 'Light sleep',
          110 => 'Deep sleep',
          111 => 'REM sleep',
          112 => 'Awake (during sleep cycle)',
          73 => 'Snowboarding',
          74 => 'Snowmobile',
          75 => 'Snowshoeing',
          76 => 'Squash',
          77 => 'Stair climbing',
          78 => 'Stair-climbing machine',
          79 => 'Stand-up paddleboarding',
          3 => 'Still (not moving)',
          80 => 'Strength training',
          81 => 'Surfing',
          82 => 'Swimming',
          84 => 'Swimming (open water)',
          83 => 'Swimming (swimming pool)',
          85 => 'Table tennis (ping pong)',
          86 => 'Team sports',
          87 => 'Tennis',
          5 => 'Tilting (sudden device gravity change)',
          88 => 'Treadmill (walking or running)',
          4 => 'Unknown (unable to detect activity)',
          89 => 'Volleyball',
          90 => 'Volleyball (beach)',
          91 => 'Volleyball (indoor)',
          92 => 'Wakeboarding',
          7 => 'Walking',
          93 => 'Walking (fitness)',
          94 => 'Nording walking',
          95 => 'Walking (treadmill)',
          96 => 'Waterpolo',
          97 => 'Weightlifting',
          98 => 'Wheelchair',
          99 => 'Windsurfing',
          100 => 'Yoga',
          101 => 'Zumba' }

        activities[number]
    end
  end
  # rubocop:enable Metrics/ClassLength, Metrics/MethodLength
end
