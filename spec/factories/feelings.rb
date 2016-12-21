FactoryGirl.define do
  factory :feeling do
  	sequence(:name) { |n| "Confused#{n}" }
  end
end
