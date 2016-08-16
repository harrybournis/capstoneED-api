FactoryGirl.define do

  require 'Faker'

  factory :user do
  	# sequence(:first_name) { |n| "Jim#{n}" }
  	# sequence(:last_name) { |n| "Tzatzikoforos#{n}" }
  	# sequence(:user_name) { |n| "jim_tzatzikoforos_#{n}" }
  	# sequence(:email) { |n| "Johntzatzikoforos#{n}@gmail.com" }
  	# sequence(:uid) { |n| "i7sqeESEDJHUSBZd4HJN42o#{n}" }
  	first_name 	{ Faker::Name.first_name }
  	last_name 	{ Faker::Name.last_name }
  	email 		{ Faker::Internet.free_email }
  	uid 		{ SecureRandom.base64(32) }
    provider { 'test' }
  end
end
