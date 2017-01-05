class AddProjectNameTeamNameToProject < ActiveRecord::Migration[5.0]
  def change
    rename_column :projects, :name, :project_name
    add_column :projects, :team_name, :string
  end
end
