class CreateStudentsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :students_projects do |t|
      t.integer :project_id
      t.integer :student_id
      t.string :nickname
    end
    add_index :students_projects, :project_id
    add_index :students_projects, :student_id
  end
end
