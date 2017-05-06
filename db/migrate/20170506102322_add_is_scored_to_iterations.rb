class AddIsScoredToIterations < ActiveRecord::Migration[5.0]
  def change
    add_column :iterations, :is_scored, :boolean
  end
end
