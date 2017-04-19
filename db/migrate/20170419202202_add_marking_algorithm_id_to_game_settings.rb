class AddMarkingAlgorithmIdToGameSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :game_settings, :marking_algorithm_id, :integer
  end
end
