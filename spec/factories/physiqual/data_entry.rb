FactoryGirl.define do
  factory :data_entry, class: Physiqual::DataEntry do
    measurement_moment Date.new(2015, 0o6, 0o1).to_time
    start_date Date.new(2015, 0o6, 0o1).to_time
    end_date Date.new(2015, 0o6, 21).to_time
    values [1, 2, 3, 4, 5]
  end
end
