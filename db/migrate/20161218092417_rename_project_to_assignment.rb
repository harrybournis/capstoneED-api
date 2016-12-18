class RenameProjectToAssignment < ActiveRecord::Migration[5.0]
  def change
  	rename_table :projects, :assignments
  end
end
