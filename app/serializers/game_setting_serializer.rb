class GameSettingSerializer < Base::BaseSerializer
  attributes  :assignment_id,
              :points_log,
              :points_log_first_of_day,
              :points_peer_assessment,
              :points_peer_assessment_first_of_team,
              :points_project_evaluation,
              :points_project_evaluation_first_of_team,
              :points_project_evaluation_submitted_first_day,
              :points_peer_assessment_submitted_first_day,
              :max_logs_per_day

  type 'game_settings'
end
