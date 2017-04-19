FactoryGirl.define do
  factory :iteration_mark do
    association :student, factory: :student
    association :iteration, factory: :iteration
    mark { nil }
    pa_score { nil }

    factory :iteration_mark_score_only do
      pa_score { 0.10..1.10 }

      factory :iteration_mark_marked do
        mark { (40..85).to_a.sample }
      end
    end
  end
end
