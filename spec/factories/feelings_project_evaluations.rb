FactoryBot.define do
  factory :feelings_project_evaluation do
    association :feeling, factory: :feeling
    association :project_evaluation, factory: :project_evaluation
    percent { rand(0..100) }
  end
end
