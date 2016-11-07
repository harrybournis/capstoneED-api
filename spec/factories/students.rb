FactoryGirl.define do
  factory :student do
    first_name 	      { "Jonathan#{rand(1000).to_s}" }
  	last_name 	      { "Burgerhuman#{rand(1000).to_s}" }
    nickname          { "Jonathan_burgerhuman_#{rand(1000).to_s}" }
    email             { "jonathan#{rand(1000).to_s}burgerhuman#{rand(1000).to_s}@gmail.com" }
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
        end
      end
    end
  end
end
