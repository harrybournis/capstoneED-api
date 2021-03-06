FactoryGirl.define do
  factory :student do
    first_name        { "Jonathan#{rand(1000).to_s}" }
    last_name         { "Burgerhuman#{rand(1000).to_s}" }
    email             { "jonathan#{rand(100000).to_s}burgerhuman#{rand(100000).to_s}@gmail.com" }
    provider          { 'test' }
    type              { 'Student' }

    factory :student_with_password do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'

      factory :student_confirmed do
        after :build do |obj|
          obj.skip_confirmation_notification!
          obj.save
          obj.confirm
          create :student_profile, student: obj
        end
      end
    end

    factory :student_confirmed_seeder do
      first_name     { Faker::Name.first_name }
      last_name     { Faker::Name.last_name }
      email       { Faker::Internet.email }
      provider    { 'email' }
      password '12345678'
      password_confirmation '12345678'

      after :build do |obj|
        obj.skip_confirmation_notification!
        obj.save
        obj.confirm
          create :student_profile, student: obj
      end
    end
  end
end
