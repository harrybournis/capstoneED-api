class AddColorToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :color, :string
  end
end
