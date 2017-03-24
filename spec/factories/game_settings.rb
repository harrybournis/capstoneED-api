FactoryGirl.define do
  factory :game_setting do
    points_log { 10 }
    points_log_first_of_day { 10 }
    points_log_first_of_team { 10 }
    points_log_first_of_assignment { 10 }
    points_peer_assessment { 10 }
    points_peer_assessment_first_of_day { 10 }
    points_peer_assessment_first_of_team { 10 }
    points_peer_assessment_first_of_assignment { 10 }
    points_project_evaluation { 10 }
    points_project_evaluation_first_of_day { 10 }
    points_project_evaluation_first_of_team { 10 }
    points_project_evaluation_first_of_assignment { 10 }

    association :assignment, factory: :assignment
  end
end
