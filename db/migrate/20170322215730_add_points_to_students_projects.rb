class AddPointsToStudentsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :students_projects, :points, :integer, default: 0
  end
end
