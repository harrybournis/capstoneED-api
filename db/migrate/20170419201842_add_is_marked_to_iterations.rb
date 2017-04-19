class AddIsMarkedToIterations < ActiveRecord::Migration[5.0]
  def change
    add_column :iterations, :is_marked, :boolean
  end
end
