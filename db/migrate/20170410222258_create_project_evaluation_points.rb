class CreateProjectEvaluationPoints < ActiveRecord::Migration[5.0]
  def change
    create_table :project_evaluation_points do |t|
      t.integer :points
      t.integer :reason_id
      t.integer :student_id
      t.integer :project_evaluation_id
      t.integer :project_id
      t.datetime :date

      t.timestamps
    end
    add_index :project_evaluation_points, :reason_id
    add_index :project_evaluation_points, :student_id
    add_index :project_evaluation_points, :project_evaluation_id
    add_index :project_evaluation_points, :project_id
  end
end
