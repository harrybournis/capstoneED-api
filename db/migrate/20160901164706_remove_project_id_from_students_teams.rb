class RemoveProjectIdFromStudentsTeams < ActiveRecord::Migration[5.0]
  def change
  	remove_column :students_teams, :project_id
  end
end
