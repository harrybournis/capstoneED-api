class RemovePointsPeerAssessmentFirstOfDayFromGameSettings < ActiveRecord::Migration[5.0]
  def change
    remove_column :game_settings, :points_peer_assessment_first_of_day
    remove_column :game_settings, :points_project_evaluation_first_of_day
  end
end
