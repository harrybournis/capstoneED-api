class CreateFeelingsProjectEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :feelings_project_evaluations do |t|
      t.integer :feeling_id
      t.integer :project_evaluation_id
      t.integer :percent

      t.timestamps
    end
    add_index :feelings_project_evaluations, :feeling_id
    add_index :feelings_project_evaluations, :project_evaluation_id
  end
end
