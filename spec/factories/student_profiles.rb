FactoryGirl.define do
  factory :student_profile do
    association :student,factory: :student_confirmed
    total_xp { rand(468) }
    level { 1 }
  end
end
