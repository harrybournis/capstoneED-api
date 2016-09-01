FactoryGirl.define do
  factory :student do
    first_name 	      { Faker::Name.first_name }
  	last_name 	      { Faker::Name.last_name }
    email             { "#{first_name}_#{last_name}#{rand(1000).to_s}@gmail.com" }
    provider          { 'test' }

    factory :student_with_password do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
    end
  end
end
