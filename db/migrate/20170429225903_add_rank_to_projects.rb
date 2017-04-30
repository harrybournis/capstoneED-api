class AddRankToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :rank, :integer
  end
end
