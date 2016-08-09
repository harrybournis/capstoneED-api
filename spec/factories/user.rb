FactoryGirl.define do
  factory :user do
  	sequence(:first_name, 1) { |n| "Jim#{n}" }
  	sequence(:last_name, 1) { |n| "Tzatzikoforos#{n}" }
  	sequence(:user_name, 1) { |n| "jim_tzatzikoforos_#{n}" }
  	sequence(:email, 1) { |n| "Johntzatzikoforos#{n}@gmail.com" }
  	uid { SecureRandom.base58(24) }
  end
end
