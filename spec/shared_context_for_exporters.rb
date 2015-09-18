module Exporters
  shared_context 'exporter context' do
    let(:user) { FactoryGirl.create(:user) }
    let(:last_measurement_time) { Time.now.change(hour: 22, min: 00) }
    let(:from) { Time.new(2015, 7, 4, 0, 0).in_time_zone }
    let(:to) { Time.new(2015, 8, 4, 0, 0).in_time_zone }
    let(:mock_result) do
      {
        '2015-08-03 10:00:00 +0200' => { heart_rate: 87.0, steps: 924, calories: 17, activities: 'Walking' },
        '2015-08-03 16:00:00 +0200' => { heart_rate: 49.0, steps: 540, calories: 46, activities: 'Moving' },
        '2015-08-03 22:00:00 +0200' => { heart_rate: 68.0, steps: 270, calories: 53, activities: 'Moving' }
      }
    end
  end
end
