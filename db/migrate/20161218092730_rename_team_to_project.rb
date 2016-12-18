class RenameTeamToProject < ActiveRecord::Migration[5.0]
  def change
  	rename_column :teams, :project_id, :assignment_id
  	rename_table :teams, :projects
  	rename_column :students_teams, :team_id, :project_id
  	rename_table :students_teams, :students_projects
  	rename_column :extensions, :team_id, :project_id
  end
end
