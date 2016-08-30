FactoryGirl.define do
  factory :lecturer do
    first_name 	    { Faker::Name.first_name }
  	last_name 	    { Faker::Name.last_name }
  	email           { "#{first_name}_#{last_name}#{rand(1000).to_s}@gmail.com" }
    provider 		    { 'test' }
    university 	    { Faker::University.name }
    position	      { Faker::Name.title }

    factory :lecturer_with_password do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
    end

    factory :lecturer_with_units do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
      units { [FactoryGirl.create(:unit), FactoryGirl.create(:unit)] }
    end

    factory :lecturer_with_units_projects_teams do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
      units     { [FactoryGirl.create(:unit), FactoryGirl.create(:unit)] }
      projects  { [FactoryGirl.create(:project_with_teams), FactoryGirl.create(:project_with_teams)] }
    end
  end
end
