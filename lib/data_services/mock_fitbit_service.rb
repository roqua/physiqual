module DataServices
  class MockFitbitService < DataService
    def service_name
      'fitbit'
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

    def heart_rate(_from, _to)
    end

    def sleep(_from, _to)
    end

    def steps(_from, _to)
    end
  end
end
