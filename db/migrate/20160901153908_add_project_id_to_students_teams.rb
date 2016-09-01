class AddProjectIdToStudentsTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :students_teams, :project_id, :integer
    add_index :students_teams, :project_id
  end
end
