class RenameIterationsProjectIdToAssingmentId < ActiveRecord::Migration[5.0]
  def change
  	rename_column :iterations, :project_id, :assignment_id
  end
end
