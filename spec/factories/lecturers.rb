FactoryBot.define do
  factory :lecturer do
    first_name      { "Alfredo#{rand(1000)}" }
    last_name       { "Jumpveryhigh#{rand(1000)}" }
    email           { "alfredo#{rand(100_000)}_jump#{rand(100_000)}@gmail.com" }
    provider { 'test' }
    university { 'University of Important Potato' }
    position { 'Master of Parking' }
    type { 'Lecturer' }

    factory :lecturer_with_password do
      provider { 'email' }
      password { '12345678' }
      password_confirmation { '12345678' }

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
      password { '12345678' }
      password_confirmation { '12345678' }

      after :build do |obj|
        obj.skip_confirmation_notification!
        obj.save
        obj.confirm
      end
    end

    factory :lecturer_with_units do
      provider { 'email' }
      password { '12345678' }
      password_confirmation { '12345678' }
      units { [FactoryBot.create(:unit), FactoryBot.create(:unit)] }
    end

    factory :lecturer_with_units_assignments_projects do
      provider { 'email' }
      password { '12345678' }
      password_confirmation { '12345678' }
      units { [FactoryBot.create(:unit), FactoryBot.create(:unit)] }
      assignments { [FactoryBot.create(:assignment_with_projects), FactoryBot.create(:assignment_with_projects)] }
    end
  end
end
