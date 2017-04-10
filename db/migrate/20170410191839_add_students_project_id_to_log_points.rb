class AddStudentsProjectIdToLogPoints < ActiveRecord::Migration[5.0]
  def change
    add_column :log_points, :students_project_id, :integer
    add_index :log_points, :students_project_id
  end
end
