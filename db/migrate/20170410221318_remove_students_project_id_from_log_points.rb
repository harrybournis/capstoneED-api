class RemoveStudentsProjectIdFromLogPoints < ActiveRecord::Migration[5.0]
  def change
    remove_column :log_points, :students_project_id
  end
end
