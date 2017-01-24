class AddUnitIdToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :unit_id, :integer
    add_index :projects, :unit_id
  end
end
