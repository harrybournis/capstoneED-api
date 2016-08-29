FactoryGirl.define do
  factory :unit do
    name { Faker::Company.catch_phrase }
    code { Faker::Code.asin }
    semester { ['Spring', 'Autumn'].sample }
    year { Faker::Date.forward.year }
    archived_at nil
    association  	:department, factory: :department
    association 	:lecturer, factory: :lecturer
  end
end
