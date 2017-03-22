class CreateGameSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :game_settings do |t|
      t.integer :assignment_id

      t.integer :points_log
      t.integer :points_log_first_of_day
      t.integer :points_log_first_of_team
      t.integer :points_log_first_of_assignment

      t.integer :points_peer_assessment
      t.integer :points_peer_assessment_first_of_day
      t.integer :points_peer_assessment_first_of_team
      t.integer :points_peer_assessment_first_of_assignment

      t.integer :points_project_evaluation
      t.integer :points_project_evaluation_first_of_day
      t.integer :points_project_evaluation_first_of_team
      t.integer :points_project_evaluation_first_of_assignment
    end
    add_index :game_settings, :assignment_id
  end
end
