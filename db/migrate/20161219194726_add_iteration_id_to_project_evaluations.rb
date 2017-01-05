class AddIterationIdToProjectEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :project_evaluations, :iteration_id, :integer
    add_index :project_evaluations, :iteration_id
  end
end
