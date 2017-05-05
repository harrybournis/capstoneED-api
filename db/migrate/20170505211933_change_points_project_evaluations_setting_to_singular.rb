class ChangePointsProjectEvaluationsSettingToSingular < ActiveRecord::Migration[5.0]
  def change
    rename_column :game_settings, :points_project_evaluations_submitted_first_day, :points_project_evaluation_submitted_first_day
  end
end
