FactoryGirl.define do
  factory :department do
    name 				{ Faker::Commerce.department }
    university 	{ Faker::Educator.university }
  end
end
