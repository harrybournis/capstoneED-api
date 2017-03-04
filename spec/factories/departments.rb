FactoryGirl.define do
  factory :department do
    name				{ "Computer Science#{rand(100000).to_s}" }
    university 	{ "University of #{rand(100000).to_s}" }

    factory :department_seeder do
      name        { Faker::StarWars.character }
      university  { Faker::University.name }
    end
  end
end
