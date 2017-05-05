class AddPointsProjectEvaluationSubmittedFirstOfDayToGameSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :game_settings, :points_project_evaluations_submitted_first_day, :integer
    add_column :game_settings, :points_peer_assessment_submitted_first_day, :integer
  end
end
