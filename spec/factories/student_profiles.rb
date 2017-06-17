FactoryGirl.define do
  factory :student_profile do
    association :student, factory: :student_confirmed
    total_xp { rand(1000) }
    level { 1 }
  end
end
