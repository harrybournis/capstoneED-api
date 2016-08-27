FactoryGirl.define do
  factory :lecturer do
    first_name 	{ Faker::Name.first_name }
  	last_name 	{ Faker::Name.last_name }
  	email 			{ Faker::Internet.free_email }
    provider 		{ 'test' }
    university 	{ Faker::University.name }
    position 		{ Faker::Name.title }

    factory :lecturer_with_password do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
    end
  end
end
