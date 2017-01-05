class AddNicknameToStudentsProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :students_projects, :nickname, :string
  end
end
