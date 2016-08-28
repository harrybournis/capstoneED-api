FactoryGirl.define do
  factory :project do
    start_date  { Date.today }
    end_date 	  { Faker::Date.forward }
  	description { Faker::Lorem.paragraph }
    association :lecturer, factory: :lecturer
    association :unit,     factory: :unit
  end
end
