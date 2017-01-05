class MoveDescriptionFromAssignmentToProject < ActiveRecord::Migration[5.0]
  def change
  	remove_column :assignments, :description
  	add_column :projects, :description, :string
  end
end
