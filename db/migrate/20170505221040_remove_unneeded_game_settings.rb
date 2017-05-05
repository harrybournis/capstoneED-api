class RemoveUnneededGameSettings < ActiveRecord::Migration[5.0]
  def change
    remove_column :game_settings, :points_log_first_of_assignment
    remove_column :game_settings, :points_log_first_of_team
    remove_column :game_settings, :points_peer_assessment_first_of_assignment
    remove_column :game_settings, :points_project_evaluation_first_of_assignment
  end
end
