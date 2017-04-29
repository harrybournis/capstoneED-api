class AddFeelingsAverageToProjectEvaluations < ActiveRecord::Migration[5.0]
  def change
    remove_column :project_evaluations, :feeling_id, :integer
    add_column :project_evaluations, :feelings_average, :decimal
  end
end
