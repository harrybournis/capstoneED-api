FactoryGirl.define do

  factory :user do
    first_name  { "Alive#{rand(1000).to_s}" }
    last_name   { "Person#{rand(1000).to_s}" }
    email     { "alive#{rand(1000).to_s}person#{rand(1000).to_s}@gmail.com" }
    provider { 'test' }

    factory :user_with_password do
      provider 'email'
      password '12345678'
      password_confirmation '12345678'
    end
  end
end
