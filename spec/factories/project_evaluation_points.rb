FactoryBot.define do
  factory :project_evaluation_point do
    points { [10, 5, 20, 50].sample }
    date { DateTime.now }
    project { create :project }
    project_evaluation { create :project_evaluation }
    student { project_evaluation.user }
    reason_id { [1,2,3].sample }
  end
end
