class MakeIsMarkedIsScoredDefaultToFalse < ActiveRecord::Migration[5.0]
  def change
    change_column :iterations, :is_marked, :boolean, default: false
    change_column :iterations, :is_scored, :boolean, default: false
  end
end
