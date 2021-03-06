FactoryGirl.define do
  factory :lecturer do
    first_name 	    { "Alfredo#{rand(1000).to_s}" }
  	last_name 	    { "Jumpveryhigh#{rand(1000).to_s}" }
  	email           { "alfredo#{rand(100000).to_s}_jump#{rand(100000).to_s}@gmail.com" }
    provider 		    { 'test' }
    university 	    { "University of Important Potato" }
    position	      { "Master of Parking" }
    type            { 'Lecturer' }

    factory :lecturer_with_password do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'

      factory :lecturer_confirmed do
        after :build do |obj|
          obj.skip_confirmation_notification!
          obj.save
          obj.confirm
        end
      end
    end

    factory :lecturer_confirmed_seeder do
      first_name  { Faker::StarWars.character.split(' ')[0] }
      last_name   { Faker::Name.last_name }
      email       { Faker::Internet.email }
      provider    { 'email' }
      university  { Faker::University.name }
      position    { Faker::Name.title }
      type        { 'Lecturer' }
      password '12345678'
      password_confirmation '12345678'

      after :build do |obj|
        obj.skip_confirmation_notification!
        obj.save
        obj.confirm
      end
    end

    factory :lecturer_with_units do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
      units { [FactoryGirl.create(:unit), FactoryGirl.create(:unit)] }
    end

    factory :lecturer_with_units_assignments_projects do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
      units     { [FactoryGirl.create(:unit), FactoryGirl.create(:unit)] }
      assignments  { [FactoryGirl.create(:assignment_with_projects), FactoryGirl.create(:assignment_with_projects)] }
    end
  end
end
