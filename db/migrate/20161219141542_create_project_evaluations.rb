class CreateProjectEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :project_evaluations do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :feeling_id
      t.integer :percent_complete

      t.timestamps
    end
    add_index :project_evaluations, :user_id
    add_index :project_evaluations, :project_id
    add_index :project_evaluations, :feeling_id
  end
end
