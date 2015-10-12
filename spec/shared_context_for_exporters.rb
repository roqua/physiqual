module Physiqual
  module Exporters
    shared_context 'exporter context' do
      let(:user) { FactoryGirl.create(:physiqual_user) }
      let(:first_measurement) { Time.new(2015, 7, 4, 10, 0).in_time_zone }
      let(:number_of_days) { 1 }
      let(:mock_result) do
        {
          '2015-08-03 10:00:00 +0200' => { heart_rate: 87.0, steps: 924, calories: 17, activities: 'Walking' },
          '2015-08-03 16:00:00 +0200' => { heart_rate: 49.0, steps: 540, calories: 46, activities: 'Moving' },
          '2015-08-03 22:00:00 +0200' => { heart_rate: 68.0, steps: 270, calories: 53, activities: 'Moving' }
        }
      end
    end
  end
end
