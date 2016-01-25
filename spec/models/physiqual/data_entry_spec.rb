module Physiqual
  require 'rails_helper'

  describe DataEntry do

    it 'is possible to create without the values' do
      result = described_class.new(measurement_moment: Time.now,
                          start_date: Time.now,
                          end_date: Time.now,
      )
      expect(result).to_not be_nil
    end

    it 'is possible to create without the current measurement' do
      result = described_class.new(values: [],
                                   start_date: Time.now,
                                   end_date: Time.now,
      )
      expect(result).to_not be_nil
    end

    describe 'default current measurement' do
      it 'sets a default current measurement right between start and end if no measurement moment is provided' do
        endd = Time.now
        start = endd - 10.minutes
        expected = endd - 5.minutes
        result = described_class.new(start_date: start,
                                     end_date: endd,
        )
        expect(result.measurement_moment.to_i).to eq(expected.to_i)
      end

      it 'doesnt use the default when a measuremoemnt is provided' do
        endd = Time.now
        start = endd - 10.minutes
        measurement_moment = endd - 1.minute
        expect_any_instance_of(DataEntry).to_not receive(:default_measurement_moment)
        result = described_class.new(start_date: start,
                                     end_date: endd,
                                     measurement_moment: measurement_moment
        )
        expect(result.measurement_moment).to eq(measurement_moment)
      end
    end
  end
end
