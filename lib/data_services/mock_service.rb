module DataServices
  class MockService < DataService
    # rubocop:disable Metrics/MethodLength
    def initialize(_session)
      @precision = 10.minutes
    end

    def service_name
      'mock'
    end

    def profile
      {
        user: {
          age: 24,
          avatar: 'https://static0.fitbit.com/images/profile/defaultProfile_100_male.gif',
          avatar150: 'https://static0.fitbit.com/images/profile/defaultProfile_150_male.gif',
          averageDailySteps: 12_345,
          country: 'NL',
          dateOfBirth: '1990-09-10',
          displayName: 'John',
          distanceUnit: 'METRIC',
          encodedId: '3L7Q2M',
          foodsLocale: 'en_US',
          fullName: 'John Doe',
          gender: 'MALE',
          glucoseUnit: 'METRIC',
          height: 180,
          heightUnit: 'METRIC',
          locale: 'en_US',
          memberSince: '2015-02-03',
          offsetFromUTCMillis: 7_200_000,
          startDayOfWeek: 'MONDAY',
          strideLengthRunning: 106.7,
          strideLengthWalking: 85.10000000000001,
          timezone: 'Europe/Amsterdam',
          topBadges: [],
          waterUnit: 'METRIC',
          waterUnitName: 'ml',
          weight: 90,
          weightUnit: 'METRIC'
        }
      }
    end

    def heart_rate(from, to)
      generate_time_series(from, to)
    end

    def activities(from, to)
      generate_time_series(from, to)
    end

    def sleep(from, to)
      generate_time_series(from, to)
    end

    def calories(from, to)
      generate_time_series(from, to)
    end

    def steps(from, to)
      generate_time_series(from, to)
    end
    # rubocop:enable Metrics/MethodLength
    #

    private

    def generate_time_series(from, to)
      time = from
      res = []
      while time < to
        res << {
          date_time_field => time,
          values_field => [rand(100)]
        }
        time += @precision
      end
      res
    end
  end
end
