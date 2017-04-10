class AddPointsMaxLogsPerDayToGameSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :game_settings, :max_logs_per_day, :integer
  end
end
