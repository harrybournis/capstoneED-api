class AddLogToStudentsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :students_projects, :logs, :jsonb, null: false, default: []

    add_index :students_projects, :logs, using: :gin
  end
end
